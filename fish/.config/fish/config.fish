source (status dirname)/git-aliases.fish

if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
  source /usr/share/cachyos-fish-config/cachyos-config.fish
end

bind ctrl-space accept-autosuggestion
bind ctrl-o 'tmux at || tmux new-session -s "$(basename "$PWD")"' repaint
bind ctrl-a 'tmux at'
bind ctrl-a 'tmux at' repaint

$HOME/.local/bin/mise activate fish | source

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

fish_add_path -g $HOME/.cargo/bin
fish_add_path -g $HOME/.bin

# pnpm
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
if not string match -q -- "$PNPM_HOME/bin" $PATH
  set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end
