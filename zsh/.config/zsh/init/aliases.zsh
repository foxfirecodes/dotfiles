alias rs='source ~/.zshrc;'

# Navigation {{{
alias ~='cd ~'
alias ..='cd ..'
alias dt='cd ~/Desktop'
alias dl='cd ~/Downloads'
alias dotfiles="cd $(realpath "$(dirname "$0")/../../../..")"
# }}}

# Clipboard {{{
if command -v xclip >/dev/null; then
  alias pbcopy='xclip -i -selection clipboard'
  alias pbpaste='xclip -o -selection clipboard'
fi
# }}}

# Confirmation {{{
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
alias rm='rm -i'
# }}}

# Server / Network {{{
alias header='curl -I'
alias headerc='curl -I --compress'
alias get='wget --content-disposition'
# }}}

# Sane defaults {{{
if [ "$(uname)" = Darwin ]; then
  alias ls='ls --color=auto'
else
  alias ls='ls --color=auto --group-directories-first'
fi
alias ll='ls -lahF'
# }}}

# Git {{{
alias gs='git status -s'
alias gl='git log'
alias gls='git log --pretty=oneline'
alias gd='git diff'
alias gco='git checkout '
alias gb='git branch -vv --sort=-committerdate '
alias gc='git commit -m '
alias gcf='git commit --amend'
alias ga='git add'
alias gp='git pull'
alias gpsh='git push'
alias gf='git fetch origin'
alias gfp='gf --prune'
alias gbr='git branch -r'
alias gbd='git branch -vv | grep ": gone" | awk "{print \$1}" | xargs git branch -d'
alias gbD='gbd -D'
alias gbc='git branch --show-current'
alias gr='git reset'
alias grh='gr --hard'
alias gss='git stash save'
alias gsp='git stash pop'
alias gsd='git stash drop'
alias grb='git rebase'
alias gtl='git tag | tr - \~ | sort -V | tr \~ -'
alias gm='git merge-base main HEAD'
alias gcoi='gb | fzf | cut -d "*" -f2- | awk "{print \$1}" | xargs git checkout'
alias groot='git rev-parse --show-toplevel'

alias tickets='grep -oE "[A-Z]+-[0-9]+"'
alias jql='xargs | tr " " "," | xargs -I{} echo "id in ({})"'
alias get-latest-tag-range='echo -n "$(gtl | tail -n2 | head -n1)..$(gtl | tail -n1)"'
alias get-release-tickets='git --no-pager log --pretty=oneline "$(get-latest-tag-range)" 1>&2; echo "$(tput setaf 2)\nuse the following JQL query to see all tickets:\n$(tput sgr0)$(git log --format="%s" "$(get-latest-tag-range)" | tickets | jql)"'
# }}}
 
# DB {{{
alias mongo='mongo --quiet'
# }}}

# CI/CD {{{
alias maven-deploy='mvn -DaltDeploymentRepository=local-repo::default::file://${MAVEN_REPO_PATH:-$HOME/GitHub/maven-repo} clean package deploy'
alias inspect-docker-context='printf "FROM scratch\n COPY . /" | DOCKER_BUILDKIT=1 docker build -f- -o context .'
# }}}

# Quick launchers {{{
alias vps-stats='ssh vps "TERM=$TERM" ./stats.sh'
alias note='nvim ~/notes/$(today)-notes.txt'
# }}}

# Info commands {{{
alias sysinfo='clear;neofetch;read -sk 1;echo'
alias song='echo "$(playerctl metadata artist) - $(playerctl metadata title)"'
alias localip='ip addr show | grep "inet " | grep -v "127.0.0.1" | head -n1 | awk '\''{print $2}'\'' | cut -d/ -f1'
alias lastcommit='git log -n 1 -pretty=format:"%H"'
alias md-view='node ~/GitHub/markdown-parser '
alias diskstat='df -h | grep -E '\''^/dev'\'' | sort | awk '\''{ print $1 ": " $3 "/" $2 " used (" $5 ")" }'\'''
alias today='date "+%D" | tr / -'
alias scanrepos='find . -maxdepth 2 -name .git -type d -prune | xargs dirname | sed "s;./;;g" | while read -r repo; do [ -n "$(git -C "$repo" remote -v)" ] && [ -z "$(git -C "$repo" status --porcelain)" ] && echo "$(tput setaf 2)$repo" || echo "$(tput setaf 1)$repo"; done | sort -r'
alias path='echo "$PATH" | tr : "\n"'
alias fpath='echo "$FPATH" | tr : "\n"'
# }}}

# Joke commands {{{
alias wininfo='xprop -id "$(xwininfo | grep -oE "Window id: 0x[0-9a-f]{6,7}" | cut -d" " -f3)"'
alias boopboom='kill "$(wininfo | grep _NET_WM_PID | cut -d" " -f3)"'
alias boxify='cowsay -W "$(( $(tput cols) - 3))" | head -n -5'
alias chill='screen -dmS music mpsyt /lunacy chillout, "$(( RANDOM % 20 ))"'
# }}}

# Docker aliases {{{
alias rustscan='docker run -it --rm --name rustscan rustscan/rustscan:latest'
# }}}

# node aliasees {{{
alias sirv='pnpm dlx sirv-cli@latest --dev'
alias nuxi='pnpm dlx nuxi@latest'
# }}}
