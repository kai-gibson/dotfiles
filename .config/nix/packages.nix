{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Terminal utilities
    git
    tmux
    lf
    neofetch
    bat
    fd
    fzf
    lazygit
    neovim
    p7zip
    ripgrep
    trash-cli
    ueberzug
    feh
    xdragon
    bleachbit
    auto-cpufreq
    tlp
    github-cli
    htop

    # Apps
    brave
    rofi
    kitty
    arandr
    logseq
    virt-manager

    # System tools
    picom
    lxsession
    networkmanagerapplet
    dwmblocks
    udiskie
    cbatticon
    nextcloud-client

    # Libraries, themes 
    tela-icon-theme
    nordic
    python
    nodejs

  ];
 
  ## PACKAGE CONFIG ##

  # Fonts

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];
  
  # Package overlays
  # Note: this won't work unless you've pulled my dotfiles

  nixpkgs.overlays = [
    (self: super: {
      dwm = super.dwm.overrideAttrs (_: { src = /home/kai/.config/dwm-kai;});
    })
    (self: super: {
      dwmblocks = super.dwmblocks.overrideAttrs (_: { src = /home/kai/.config/dwmblocks-kai;});
    })
  ];

  users.defaultUserShell = pkgs.fish;
}
