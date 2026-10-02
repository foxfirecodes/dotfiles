fundle plugin oh-my-fish/plugin-bang-bang
fundle plugin franciscolourenco/done
fundle plugin 'jorgebucaran/autopair.fish'
fundle init

source (status dirname)/git-aliases.fish

if test -f ~/.config/fish/local-config.fish
    source ~/.config/fish/local-config.fish
end

if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

bind ctrl-space accept-autosuggestion
bind ctrl-o 'tmux at || tmux new-session -s "$(basename "$PWD")"' repaint
bind ctrl-a 'tmux at'
bind ctrl-a 'tmux at' repaint

set -gx EDITOR nvim
set -gx VISUAL $EDITOR
set -gx GPG_TTY (tty)

fish_add_path -g $HOME/.bin
fish_add_path -g $HOME/.local/bin
fish_add_path -g $HOME/.cargo/bin

if test -d $HOME/.local/share/pnpm
    set -gx PNPM_HOME $HOME/.local/share/pnpm
    fish_add_path -g $PNPM_HOME
end

if test -d /opt/homebrew/bin
    fish_add_path -g /opt/homebrew/bin
end

if type -q mise
    mise activate fish | source
end

if type -q zoxide
    zoxide init fish | source
end

if type -q starship
    source (starship init fish --print-full-init | psub)
end

function fish_greeting
    if type -q fastfetch
        fastfetch --color magenta --logo-color-1 red --logo-color-2 yellow --logo-position right
    end
end
