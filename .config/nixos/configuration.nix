# edIt this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
   nix.extraOptions = ''
      experimental-features = nix-command flakes
   '';

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./packages.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.plymouth = {
    enable = true;
    theme = "spinner";
  };

  boot.initrd.systemd.enable = true;

  system.activationScripts = {
    keychronk2fix.text =
      ''
        # Fix for the f-keys of the Keychron K2:
        echo 1 | tee /sys/module/hid_apple/parameters/swap_opt_cmd >/dev/null
        #echo 1 | tee /sys/module/hid_apple/parameters/swap_fn_leftctrl >/dev/null
      '';
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Australia/Melbourne";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.utf8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  
  # Battery optimisation
  powerManagement.powertop.enable = true;
  services.tlp.enable = true;
  services.auto-cpufreq.enable = true;

  # Enable gnome keyring
  services.gnome.gnome-keyring.enable = true;

  # Enable DWM and lightdm
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.windowManager.dwm.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable virtualisation
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "au";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kai = {
    isNormalUser = true;
    description = "Kai";
    initialPassword = "abcd";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = [ (import /home/kai/.custom-derivations/nix-search/default.nix) ];
  };

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "kai";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  # Nix storage management options

  nix.autoOptimiseStore = true;

  # Auto GC every morning
  nix.gc.automatic = false;
  services.cron.systemCronJobs = [ "0 3 * * * root /etc/admin/optimize-nix" ];
  
  environment.etc =
  {
    "admin/optimize-nix" =
    {
      text =
      ''
        #!/run/current-system/sw/bin/bash
        set -eu
  
        # Delete everything from this profile that isn't currently needed
        nix-env --delete-generations old
  
        # Delete generations older than a week
        nix-collect-garbage
        nix-collect-garbage --delete-older-than 7d
  
        # Optimize
        nix-store --gc --print-dead
        nix-store --optimise
      '';
      mode = "0774";
    };
  };

  system.userActivationScripts = {
      cloneDotfiles = {
          text = ''
          PATH=$PATH:${lib.makeBinPath [ pkgs.rsync pkgs.git ]}
          if [ $USER == "kai" ]; then
              if [ ! -e ~/.dotfiles ]; then
                  if [ -e /tmp/clonedir ]; then
                      rm -rf /tmp/clonedir
                  fi

                  git clone -b nix --bare https://github.com/kai-gibson/dotfiles.git /tmp/clonedir/.dotfiles
                  git --git-dir=/tmp/clonedir/.dotfiles --work-tree=/tmp/clonedir checkout
                  rsync -a /tmp/clonedir/ ~/
              fi
          fi
          '';
      };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leavecatenate(variables, "bootdev", bootdev)
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
