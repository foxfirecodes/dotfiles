# edits the given dotfile and then re-sources it
function dfe {
    local dotfile="$HOME/.config/zsh/init/$1"
    nvim "$dotfile" && test -f "$dotfile" && source "$dotfile"
}

function reloadfunc {
    local func="${1?missing func}"
    unset "functions[$func]"
    autoload -Uz "$func"
}

# opens path in GUI (supporting piping)
function o {
    local dir="$@"
    if [[ -z "$dir" ]] && [[ ! -t 0 ]]; then
        read -r line
        dir="$line"
    fi

    open "${dir:-.}" 1&>/dev/null
}

# locates a file
function loc {
    if [[ $# -lt 1 ]]; then
        echo "Usage: loc <query> [folder]" >&2
        return 1
    fi

    local query="$1"
    local dir="${2:-.}"

    rg --hidden --color always --line-number --ignore-case "$query" "$dir" | less -R
}

# finds a font
function fc-find {
    if [[ $# -lt 1 ]]; then
        echo "Usage: fc-find <name>" >&2
        return 1
    fi

    local fontName="$1"

    fc-list \
        | grep -i "$fontName" \
        | cut -d: -f2 \
        | sort \
        | uniq \
        | sed -e 's/^ //g' -e 's/,/, /g'
}

function sizes {
    du -sh "$@" | sort -h
}

function convert-to-mp4 {
    if [[ $# -lt 2 ]]; then
        echo "usage: convert-to-mp4 <input> <output>" >&2
        return 1
    fi

    ffmpeg -i "$1" -vcodec h264_nvenc -crf 30 -acodec copy "$2"
}

# creates an encrypted backup of the given path
function bak {
    if [[ $# -lt 1 ]]; then
        echo "usage: bak <path>" >&2
        return 1
    fi

    if [[ -z "$BAK_GPG_ID" ]]; then
        echo "BAK_GPG_ID not configured" >&2
        return 1
    fi

    mkdir -p ~/.bak
    if [[ ! -e "$1" ]]; then
        echo "'$1' does not exist" >&2
        return 1
    fi

    local bak_name="$(date "+%y-%m-%d-%H-%M-%S")-$(basename "$PWD")-$(basename "$1")"
    tar -czf - "$1" | gpg --encrypt --recipient "$BAK_GPG_ID" --output ~/.bak/"$bak_name".tar.gz.gpg
    echo "baked up as $bak_name"
}

# touch, but also chmod +x
function touchexec {
    touch "$1" && chmod +x "$1"
}

function mkscript {
    if [ ! -f "$1" ]; then
        echo "#!/bin/bash" > "$1"
    fi
    if [ ! -x "$1" ]; then
        chmod +x "$1"
    fi
}

function ai-digest {
    local out="$(mktemp)"
    bunx ai-digest -o "$out" "$@"
    pbcopy < "$out"
}

function clone {
    local repo="${1?missing repo name}"
    local repo_name="$(echo "$repo" | sed -e 's;git@github.com:.\+/\(.\+\);\1;g' -e 's;https://github.com/.\+/\(.\+\);\1;g' -e 's;\.git$;;g')"
    local repos_dir="$HOME/code"
    mkdir -p "$repos_dir"
    local out_path="$repos_dir/$repo_name"
    if echo "$repo_name" | grep -q /; then
        echo "warning: could not detect repo name" >&1
    elif [ -d "$out_path" ]; then
        echo "note: already cloned" >&1
        cd "$out_path"
    else
        git clone "$repo" "$out_path"
        cd "$out_path"
    fi
}

function mkcd {
    if [ -z "$1" ]; then
        echo "usage: mkcd <path>" >&1
        return 1
    fi
    mkdir -p "$1" && cd "$1"
}
