# ~/.bash_profile

[[ -f "$HOME/.bashrc" ]] && . "$HOME/.bashrc"

if [[ -x "$HOME/.local/bin/mise" ]]; then
  eval "$("$HOME/.local/bin/mise" activate bash)"
fi
