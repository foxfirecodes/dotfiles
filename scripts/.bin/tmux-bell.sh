#!/bin/bash

origin_session="$1"
current_session="$(tmux display-message -p '#{session_name}')"

if [ -n "$origin_session" ] && [ "$origin_session" != "$current_session" ]; then
  tmux set -t "$origin_session" @bell 1
fi

for tty in $(tmux list-clients -F '#{client_tty}'); do
  printf '\a' > "$tty"
done
