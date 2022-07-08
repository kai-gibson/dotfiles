# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/1c610d80-d94a-4538-93d9-4a6106bc2cb3";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/515175af-b0e8-4192-9f67-35a796987a7a";

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/1c610d80-d94a-4538-93d9-4a6106bc2cb3";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/var" =
    { device = "/dev/disk/by-uuid/1c610d80-d94a-4538-93d9-4a6106bc2cb3";
      fsType = "btrfs";
      options = [ "subvol=@var" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/1c610d80-d94a-4538-93d9-4a6106bc2cb3";
      fsType = "btrfs";
      options = [ "subvol=@nix" ];
    };

  fileSystems."/swap" =
    { device = "/dev/disk/by-uuid/1c610d80-d94a-4538-93d9-4a6106bc2cb3";
      fsType = "btrfs";
      options = [ "subvol=@swap" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/EB39-36D9";
      fsType = "vfat";
    };

  swapDevices = [{
    device = "/swap/swapfile";
    size = (1024 * 8);
  }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}