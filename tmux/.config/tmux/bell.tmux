# vi: ft=tmux

# listen for bells even in current window
set -g bell-action any
set -gw monitor-bell on

# custom script to send terminal bell to all active sessions
set-hook -g alert-bell 'run-shell "~/.bin/tmux-bell.sh #{session_name}"'
# the script sets @bell 1 on unfocused sessions; clear when navigating to that session
set-hook -g client-session-changed 'set @bell 0'

# override normal session selector to show notice via @bell
bind s choose-tree -sF '#{?@bell,#[fg=yellow bold]! #{session_name}#[default],#{session_name}} (#{session_windows} windows)'
