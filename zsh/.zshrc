# ---------------------------
# rayzr's personal ZSH config
# ---------------------------

# All environment variables, aliases, etc. are handled in my organized dotfiles.
for file in ~/.config/zsh/init/*.zsh(n); do
  source "$file"
done

if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi
