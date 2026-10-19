#!/bin/bash

cd "$(dirname "$0")"

has() {
  command -v "$1" >/dev/null
}

confirm() {
  local result
  read -p "$1 (y/n) " -n 1 result
  echo
  test "$result" == y
}

install_nf() {
  local name="${1?missing name}"
  (
    cd "$(mktemp -d)"
    wget "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$name.zip"
    unzip "$name.zip"
    mkdir -p ~/.local/share/fonts
    mv *.ttf ~/.local/share/fonts
    fc-cache -f
  )
}

if has apt; then
  echo "apt found"
  if confirm "would you like to install system deps?"; then
    sudo apt update
    sudo apt install build-essential git tmux zsh stow curl wget zip unzip ffmpeg imagemagick rofi xclip xdotool playerctl jq conky
  fi
fi

if ! has stow; then
  echo "missing GNU stow, please install first" >&2
  exit 1
fi

if ! has zsh; then
  echo "missing zsh, please install first" >&2
  exit 1
fi

if [[ "$SHELL" != *zsh ]]; then
  echo "current user shell is not zsh"
  if confirm "change it to $(which zsh)?"; then
    chsh -s $(which zsh)
    echo "please relog for this change to be reflected"
  fi
fi

if ! has mise; then
  echo "mise not found"
  if confirm "would you like to install it?"; then
    curl https://mise.run | sh
    eval "$(~/.local/bin/mise env)"
  fi
fi

mise_deps=("neovim" "starship" "pnpm" "node@lts")
if has mise && confirm "would you like to install (${mise_deps[*]}) with mise?"; then
  mise use -g "${mise_deps[@]}"
  eval "$(mise env)"
fi


if ! has starship; then
  echo "starship not found"
  if confirm "install starship?"; then
    curl -sS https://starship.rs/install.sh | sh
  fi
fi

if ! has nvim; then
  echo "neovim not found"
  if confirm "install neovim?"; then
    (
    cd "$(mktemp -d)"
    wget "https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
    tar -xzvf nvim-linux64.tar.gz
    sudo rsync -abu nvim-linux64/ /usr/local/
  )
  fi
fi

if ! has pnpm; then
  echo "pnpm not found"
  if confirm "install pnpm?"; then
    # hide the current shell info so it doesnt install completions bc AAAAA
    curl -fsSL https://get.pnpm.io/install.sh | env SHELL="" BASH_VERSION="" ZSH_VERSION="" sh -
  fi
fi

if ! has fc-list; then
  echo "cant manage fonts on this system, ignoring"
else
  if ! fc-list | grep -q "FiraCode Nerd Font"; then
    echo "FiraCode Nerd Font not installed"
    confirm "install it?" && install_nf FiraCode
  fi
  if ! fc-list | grep -q "Iosevka Nerd Font"; then
    echo "Iosevka Nerd Font not installed"
    confirm "install it?" && install_nf Iosevka
  fi
fi

default_stows=(zsh scripts tmux git nvim fastfetch fish)
echo "installing default stows: ${default_stows[@]}"
./stow.sh "${default_stows[@]}"
