#!/bin/sh

# Script to install NixOS

# First, grab .nix files from repo and put them in /mnt/etc
mv /mnt/etc/nixos /mnt/etc/bak_nixos
mkdir /mnt/etc/nixos
curl https://raw.githubusercontent.com/kai-gibson/dotfiles/nix/.config/nixos/configuration.nix >> /mnt/etc/nixos/configuration.nix
curl https://raw.githubusercontent.com/kai-gibson/dotfiles/nix/.config/nixos/hardware-configuration.nix >> /mnt/etc/nixos/hardware-configuration.nix
curl https://raw.githubusercontent.com/kai-gibson/dotfiles/nix/.config/nixos/packages.nix >> /mnt/etc/nixos/packages.nix

# Then install
cd /mnt
nixos-install
