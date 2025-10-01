if [ -d /opt/homebrew/bin ]; then
  add_to_path /opt/homebrew/bin prepend
fi
if [ -d /opt/homebrew/share/zsh/site-functions ]; then
  fpath+=(/opt/homebrew/share/zsh/site-functions)
fi
