#!/bin/bash

DRY_RUN=false
ALLOW_SENSITIVE=false

while [[ "$1" =~ --* ]]; do
  OPT="${1#--}"
  shift

  case "$OPT" in
    dry-run)
      DRY_RUN=true
      echo "RUNNING IN DRY RUN MODE"
      ;;
    allow-sensitive)
      ALLOW_SENSITIVE=true
      echo "WARNING: allowing sensitive paths"
      ;;
    "")
      break
      ;;
    *)
      echo "unknown flag: --$OPT"
      ;;
  esac
done

if [ $# -lt 2 ] || [ -z "$1" ] || [ -z "$2" ]; then
  echo "USAGE: watchsync.sh <source> <dest>" >&2
  exit 1
fi

SOURCE="${1%/}/"
DESTINATION="${2%/}/"

if [ ! -d "$SOURCE" ]; then
  echo "$SOURCE is not a directory" >&2
  exit 1
fi

REAL_SOURCE="$(realpath "$SOURCE")"

if [ "$ALLOW_SENSITIVE" != true ] && [ "${REAL_SOURCE#$HOME}" = "$REAL_SOURCE" ]; then
  echo "ERROR: cannot sync sensitive directory '$SOURCE' without --allow-sensitive" >&2
  exit 1
fi

RSYNC_COMMAND=(
  rsync -avz --partial --delete --filter ':- .gitignore' --exclude .git "$SOURCE" "$DESTINATION"
)

echo "--- attempting dry run... ---"

if ! "${RSYNC_COMMAND[@]}" --dry-run; then
  echo "dry run sync failed" >&2
  exit 1
fi

if [ "$DRY_RUN" = true ]; then
  echo "--- IN DRY RUN MODE, EXITING ---"
  exit
fi

echo "--- dry run successful, performing real sync ---"

stalker --markers --watch . -- "${RSYNC_COMMAND[@]}"
