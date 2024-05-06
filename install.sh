#!/bin/sh
DOTFILES_DIR=$(dirname $0)

ln -sf $DOTFILES_DIR/.zshrc ~/.zshrc

ln -sf $DOTFILES_DIR/.vimrc ~/.vimrc

if [ ! -d ~/.config/zellij ]; then
  mkdir -p ~/.config/zellij
fi
ln -sf $DOTFILES_DIR/.config/zellij/config.kdl ~/.config/zellij/config.kdl
