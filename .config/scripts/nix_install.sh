#!/bin/sh

# Script to install NixOS dotfiles

# 1. Clone dotfiles

echo ".dotfiles" >> $HOME/.gitignore
git clone --bare -b nix https://github.com/kai-gibson/dotfiles.git $HOME/.dotfiles
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout

# 2. Symlink Nix config

sudo mv /etc/nixos /etc/nixos_bak
sudo ln -s $HOME/.config/nix/ /etc/nixos

# 3. Install vim-plug

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
