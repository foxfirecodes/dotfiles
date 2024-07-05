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
