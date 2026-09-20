source (status dirname)/git-aliases.fish

if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
  source /usr/share/cachyos-fish-config/cachyos-config.fish
end

bind ctrl-space accept-autosuggestion
bind ctrl-o 'tmux at || tmux new-session -s "$(basename "$PWD")"' repaint
bind ctrl-a 'tmux at'
bind ctrl-a 'tmux at' repaint

if type -q zoxide
  zoxide init fish | source
end

if type -q starship
  source (starship init fish --print-full-init | psub)
end

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
/home/foxfire/.local/bin/mise activate fish | source

# pnpm
set -gx PNPM_HOME "/home/foxfire/.local/share/pnpm"
if not string match -q -- "$PNPM_HOME/bin" $PATH
  set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end
