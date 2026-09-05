#!/usr/bin/env bash
# Sync the shared section of ~/.ssh/config to one or more SSH hosts.
#
# Mark the section in every config with these exact lines:
#   # BEGIN SSH CONFIG SYNC
#   # END SSH CONFIG SYNC

set -u

begin_marker='# BEGIN SSH CONFIG SYNC'
end_marker='# END SSH CONFIG SYNC'
local_config="$HOME/.ssh/config"

usage() {
	cat <<'EOF'
Usage: sync-ssh-config.sh [--dry-run] HOST [HOST ...]

Copies the contents between these exact markers in ~/.ssh/config to the same
marked section of each HOST's ~/.ssh/config, leaving everything else intact:
  # BEGIN SSH CONFIG SYNC
  # END SSH CONFIG SYNC

Hosts without either marker are initialized by appending the complete marked
block. Before every real update, the remote config is backed up as
~/.ssh/config.sync-ssh-config.XXXXXX.

--dry-run prints the diff that would be applied without changing remote files.
EOF
}

die() {
	printf 'error: %s\n' "$*" >&2
	exit 2
}

marker_state() {
	local config=$1

	awk -v begin="$begin_marker" -v end="$end_marker" '
    $0 == begin { begin_count++; if (!in_block) in_block = 1; next }
    $0 == end { end_count++; if (in_block) { in_block = 0; complete_count++ }; next }
    END {
      if (begin_count == 0 && end_count == 0) print "absent"
      else if (begin_count == 1 && end_count == 1 && complete_count == 1 && !in_block) print "complete"
      else print "invalid"
    }
  ' "$config"
}

dry_run=false
while (($#)); do
	case $1 in
	--dry-run)
		dry_run=true
		shift
		;;
	-*)
		die "unknown option: $1"
		;;
	*)
		break
		;;
	esac
done

(($#)) || {
	usage >&2
	exit 2
}
[ -f "$local_config" ] || die "local config not found: $local_config"
[ "$(marker_state "$local_config")" = complete ] || die "local config must contain exactly one complete marked block"

work_dir=$(mktemp -d "${TMPDIR:-/tmp}/sync-ssh-config.XXXXXX") || exit 1
trap 'rm -rf "$work_dir"' EXIT

shared_block="$work_dir/shared-block"
awk -v begin="$begin_marker" -v end="$end_marker" '
  $0 == begin { in_block = 1; next }
  $0 == end { in_block = 0; next }
  in_block { print }
' "$local_config" >"$shared_block"

replace_block() {
	local input=$1
	local output=$2
	local state=$3

	if [ "$state" = absent ]; then
		awk -v begin="$begin_marker" -v end="$end_marker" -v shared="$shared_block" '
      { print; last = $0 }
      END {
        if (NR && last != "") print ""
        print begin
        while ((getline line < shared) > 0) print line
        close(shared)
        print end
      }
    ' "$input" >"$output"
		return
	fi

	awk -v begin="$begin_marker" -v end="$end_marker" -v shared="$shared_block" '
    $0 == begin {
      print
      while ((getline line < shared) > 0) print line
      close(shared)
      in_block = 1
      next
    }
    $0 == end { in_block = 0 }
    !in_block { print }
  ' "$input" >"$output"
}

failed=false
for host in "$@"; do
	remote_config="$work_dir/remote-config"
	updated_config="$work_dir/updated-config"
	state=

	printf '%s: fetching ~/.ssh/config\n' "$host"
	if ! ssh -- "$host" 'cat "$HOME/.ssh/config"' >"$remote_config"; then
		printf '%s: failed to read remote config\n' "$host" >&2
		failed=true
		continue
	fi

	state=$(marker_state "$remote_config")
	if [ "$state" = invalid ]; then
		printf '%s: remote config must contain exactly one complete marked block\n' "$host" >&2
		failed=true
		continue
	fi
	replace_block "$remote_config" "$updated_config" "$state"

	if cmp -s "$remote_config" "$updated_config"; then
		printf '%s: already up to date\n' "$host"
		continue
	fi

	if "$dry_run"; then
		if [ "$state" = absent ]; then
			printf '%s: would initialize the marked block and create a backup\n' "$host"
		else
			printf '%s: would update and create a backup\n' "$host"
		fi
		diff -u --label "$host:~/.ssh/config (current)" --label "$host:~/.ssh/config (new)" \
			"$remote_config" "$updated_config" || true
		continue
	fi

	if [ "$state" = absent ]; then
		printf '%s: initializing ~/.ssh/config\n' "$host"
	else
		printf '%s: updating ~/.ssh/config\n' "$host"
	fi
	if ! ssh -- "$host" 'set -eu
    umask 077
    temp=$(mktemp "$HOME/.ssh/config.XXXXXX")
    trap '\''rm -f "$temp"'\'' EXIT HUP INT TERM
    cat > "$temp"
    chmod 600 "$temp"
    backup=$(mktemp "$HOME/.ssh/config.sync-ssh-config.XXXXXX")
    if ! cp -p "$HOME/.ssh/config" "$backup"; then
      rm -f "$backup"
      exit 1
    fi
    mv "$temp" "$HOME/.ssh/config"
    printf "backup: %s\\n" "$backup"
  ' <"$updated_config"; then
		printf '%s: failed to update remote config\n' "$host" >&2
		failed=true
	fi
done

"$failed" && exit 1
