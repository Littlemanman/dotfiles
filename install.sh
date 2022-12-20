#!/bin/sh
ln -sf $(pwd)/.zshrc ~/.zshrc

ln -sf $(pwd)/.vimrc ~/.vimrc

if [ ! -d ~/.config/zellij ]; then
  mkdir -p ~/.config/zellij
fi
ln -sf $(pwd)/.config/zellij/config.kdl ~/.config/zellij/config.kdl
