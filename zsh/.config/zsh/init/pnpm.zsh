if [ -d ~/.local/share/pnpm ]; then
  export PNPM_HOME="$HOME/.local/share/pnpm"
  add_to_path "$PNPM_HOME"
elif [ -d ~/Library/pnpm ]; then
  export PNPM_HOME="$HOME/Library/pnpm"
  add_to_path "$PNPM_HOME"
fi
