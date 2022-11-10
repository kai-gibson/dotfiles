{ config, pkgs, lib, ... }: 
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  environment.systemPackages = with pkgs; [
    # Terminal utilities
    git
    tmux
    lf
    neofetch
    bat
    fd
    fzf
    unstable.lazygit
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
    moc
    powertop
    mimeo
    file
    xclip
    bluez
  
    # Apps
    brave
    rofi
    kitty
    arandr
    logseq
    virt-manager
    pavucontrol
    flameshot
    zathura
    discord
    zotero
    unstable.signal-desktop
    darktable
    calibre

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
    #python3
    #jdk11
    nodejs
    gcc
    zsh-autosuggestions
    zsh-fast-syntax-highlighting
  ];
  
  
  ## PACKAGE CONFIG ##
  
  # Fonts
  
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];
  
  # Package overlays
  
  /* nixpkgs.overlays = [ */
  /*   (self: super: { */
  /*     dwm = super.dwm.overrideAttrs (_: { src = /home/kai/.config/dwm-kai;}); */
  /*   }) */
  /*   (self: super: { */
  /*     dwmblocks = super.dwmblocks.overrideAttrs (_: { src = /home/kai/.config/dwmblocks-kai;}); */
  /*   }) */
  /* ]; */
  
  nixpkgs.overlays = [
    (self: super: {
      dwm = super.dwm.overrideAttrs (_: { 
          src = builtins.fetchGit {
              url = "https://github.com/kai-gibson/dwm-kai.git";
              ref = "nix";
          };
      });
    })
  
    (self: super: {
      dwmblocks = super.dwmblocks.overrideAttrs (_: { 
          src = builtins.fetchGit {
              url = "https://github.com/kai-gibson/dwmblocks-kai.git";
              ref = "main";
          };
      });
    })
  
    (self: super: {
        neovim = super.neovim.override {
            viAlias = true;
            vimAlias = true;
        };
    })
  ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  }; 
}
