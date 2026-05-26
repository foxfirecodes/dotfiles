# vi: ft=tmux

# enable mouse control (clickable windows, panes, resizable panes)
set -g mouse on

# remap prefix from C-b to C-a
unbind C-b
set -g prefix C-a

# quick detach from tmux
bind -n C-x detach-client

# re-number windows automatically
bind C-r move-window -r

# quickly tab through windows
bind -r Tab next-window

# clipboard shortcuts
bind -T copy-mode y send-keys -X copy-pipe-and-cancel "xsel -i -p && xsel -o -p | xsel -i -b"
# bind C-y run "xsel -o | tmux load-buffer - ; tmux paste-buffer"

# fzf session selector
bind C-s display-popup -E -w 80% -h 70% -T "Sessions" "session=\$(tmux list-sessions -F '#{session_last_attached} #{session_name}#{?@bell, *,}' | sort -rn | sed 's/^[0-9]* //' | fzf --prompt='session> ' --no-multi --no-sort --reverse | sed 's/ \*$//') && [ -n \"\$session\" ] && tmux switch-client -t \"\$session\""

# switch to previous session and kill the original
bind X confirm-before -p "Kill session #S? (y/n)" "run-shell 'session=#{q:session_name}; tmux switch-client -l && tmux kill-session -t \"\$session\"'"

# zoxide session creator
bind N display-popup -EE -w 80% -h 70% -T "New Session" "zsh -ic 'zi || exit; default=\${PWD:t}; printf \"session name [%s]: \" \"\$default\"; read -r name; name=\${name:-\$default}; tmux new-session -d -s \"\$name\" -c \"\$PWD\" && tmux switch-client -t \"\$name\"'"
