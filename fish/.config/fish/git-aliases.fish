# Git shortcuts from zsh/.config/zsh/init/aliases.zsh.
alias gs 'git status -s'
alias gl 'git log'
alias gls 'git log --pretty=oneline'
alias gd 'git diff'
alias gco 'git checkout'
alias gb 'git branch -vv --sort=-committerdate'
alias gc 'git commit -m'
alias gcf 'git commit --amend'
alias ga 'git add'
alias gp 'git pull'
alias gpsh 'git push'
alias gf 'git fetch origin'
alias gfp 'gf --prune'
alias gbr 'git branch -r'
alias gbd "git branch -vv | grep ': gone' | awk '{print \$1}' | xargs git branch -d"
alias gbD 'gbd -D'
alias gbc 'git branch --show-current'
alias gr 'git reset'
alias grh 'gr --hard'
alias gss 'git stash'
alias gsp 'git stash pop'
alias gsd 'git stash drop'
alias grb 'git rebase'
alias gtl 'git tag | tr - \~ | sort -V | tr \~ -'
alias gm 'git merge-base main HEAD'
alias gcoi "gb | fzf | cut -d '*' -f2- | awk '{print \$1}' | xargs git checkout"
alias groot 'git rev-parse --show-toplevel'
alias gmct 'git status -s | grep -E "^\w\w" | cut -d" " -f2- | xargs git checkout --theirs'
alias gmcd 'git status -s | grep -E "^\w\w" | cut -d" " -f2- | xargs git diff HEAD'

alias tickets 'grep -oE "[A-Z]+-[0-9]+"'
alias jql 'xargs | tr " " "," | xargs -I{} echo "id in ({})"'

function get-latest-tag-range
    printf '%s..%s' (gtl | tail -n2 | head -n1) (gtl | tail -n1)
end

function get-release-tickets
    set -l tag_range (get-latest-tag-range)
    git --no-pager log --pretty=oneline "$tag_range" >&2
    printf '%s\nuse the following JQL query to see all tickets:\n%s%s\n' \
        (tput setaf 2) (tput sgr0) (git log --format=%s "$tag_range" | tickets | jql)
end

alias lastcommit 'git log -n 1 --pretty=format:"%H"'

function scanrepos
    for repo in (find . -maxdepth 2 -name .git -type d -prune | xargs dirname)
        set -l repo (string replace -r '^\./' '' -- "$repo")
        if test -n "$(git -C "$repo" remote -v)"; and test -z "$(git -C "$repo" status --porcelain)"
            printf '%s%s\n' (tput setaf 2) "$repo"
        else
            printf '%s%s\n' (tput setaf 1) "$repo"
        end
    end | sort -r
end
