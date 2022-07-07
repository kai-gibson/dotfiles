# Kai's Dotfiles for NixOS

## To Install:
Before installing, it's best to delete everything in .config, .local/bin,
and .local/share/fonts
```
echo ".dotfiles" >> .gitignore
git clone --bare -b nix https://github.com/kai-gibson/dotfiles.git $HOME/.dotfiles
alias config='/usr/bin/env git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
config checkout
```
## Includes configs for:
- Fish shell
- Kitty terminal emulator
- Lf file manager
- Neovim (as an IDE)
- Rofi
- Tmux

## And Custom builds of:
- Dwm
- Dwm blocks

## Dependencies:
- System:
    - git
    - fish
    - kitty
    - rofi
    - lf
    - neovim
    - tmux
    - lxappearance
    - lightdm
    - neofetch
    - tlp
    - tlp ui
    - autocpufreq
- Dwm autostart:
    - feh
    - picom
    - lxsession
    - udiskie
    - cbatticon
    - nextcloud-client
    - nm-applet
    - brave
    - logseq
    - kitty
- Neovim and Lf:
    - nodejs
    - bat
    - fzf
    - ripgrep
    - fd
    - lazygit
    - trash-cli
    - dragon-drop
    - p7zip
    - bleachbit
    - ueberzug