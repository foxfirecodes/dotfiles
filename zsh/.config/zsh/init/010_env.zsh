# configure tools
export EDITOR=nvim
export VISUAL="$EDITOR"

# passwordless sudo via keychain
# if [ "$XDG_SESSION_TYPE" != tty ] && command -v secret-tool >/dev/null; then
#     export SUDO_ASKPASS="$HOME/.bin/askpass-secret-tool"
#     alias sudo="sudo -A"
# fi

# fix gpg
export GPG_TTY=$(tty)

add_to_path "$HOME/.local/bin"
add_to_path "$HOME/.bin"
add_to_path "./node_modules/.bin"
add_to_path "./target/debug"

if [ -f "/etc/wsl.conf" ]; then
   add_to_path "$HOME/.bin/wsl"
fi

# Safely restore GUI environment variables from systemd if they are missing
if [ -z "$DISPLAY" ] || [ -z "$XAUTHORITY" ]; then
    # Cache the systemd user environment output to avoid multiple process forks
    _SYSTEMD_GUI_ENV=$(systemctl --user show-environment 2>/dev/null)

    if [ -n "$_SYSTEMD_GUI_ENV" ]; then
        [ -z "$DISPLAY" ] && export DISPLAY=$(echo "$_SYSTEMD_GUI_ENV" | grep '^DISPLAY=' | cut -d= -f2-)
        [ -z "$XAUTHORITY" ] && export XAUTHORITY=$(echo "$_SYSTEMD_GUI_ENV" | grep '^XAUTHORITY=' | cut -d= -f2-)
    fi
    unset _SYSTEMD_GUI_ENV
fi
