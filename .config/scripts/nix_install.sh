#!/usr/bin/env bash

# Script to install NixOS

# First, check if internet is connected
if nc -zw1 google.com 443; then

    # If yes, start install
    echo "Internet connected! Starting Install"
    echo "Installing required tools..."

    nix-env -iA nixos.git
    
# Get disk name
    DISK_LIST=$(lsblk -l | tail -n +2 | awk '{print $1}')

    echo "Please select disk:"
    echo "(WARNING: The selected disk will be completely wiped)"

    select DISK in $DISK_LIST
    do
        if [ -z $(echo " $(lsblk -l | tail -n +2 | awk '{print $1}') " | grep -woP "$DISK") ]; 
        then 
            echo "Invalid input"; 
        else
            break
        fi
    done

    # Disk name is now stored in $DISK

# Make partitions
    echo "Making Partitions..."
    echo -e "g\nn\n\n\n+500M\nt\n\n1\nn\n\n\n\np\nw\n" | fdisk /dev/$DISK
    echo "Partitioning Finished"

# Encrypt disk 
    VALID=no
    while [ $VALID != "yes" ]
    do
        echo "Enter Encryption Key:"
        read ENCRYPTION_KEY
    
        echo "Confirm Key:"
        read VALIDATE_ENCRYPTION_KEY
    
        if [ $ENCRYPTION_KEY == $VALIDATE_ENCRYPTION_KEY ]; then
            VALID=yes
        else
            echo "Passwords don't match, please try again"
        fi
    done 
    
    echo "Encrypting Root Partition ..."
    echo -n $ENCRYPTION_KEY | cryptsetup luksFormat /dev/"$DISK"2 - --label NIXENC
    echo -n $ENCRYPTION_KEY | cryptsetup open /dev/"$DISK"2 cryptroot -
    ENCRYPTION_KEY=''
    echo "Encryption Successful"

# Make Filesystem
    echo "Making Filesystem and Mounting Disks..."
    mkfs.vfat -n NIXBOOT /dev/"$DISK"1
    mkfs.btrfs -L NIXROOT /dev/mapper/cryptroot
    mount /dev/mapper/cryptroot /mnt
    btrfs subvol create /mnt/@
    btrfs subvol create /mnt/@home
    btrfs subvol create /mnt/@var
    btrfs subvol create /mnt/@swap
    btrfs subvol create /mnt/@nix

# Mount Subvolumes and Partitions
    umount /mnt
    mount -t btrfs -o subvol=@,ssd,compress=zstd,discard /dev/mapper/cryptroot /mnt
    mkdir /mnt/{boot,home,var,swap,nix}

    mount -t btrfs -o subvol=@home,ssd,compress=zstd,discard /dev/mapper/cryptroot /mnt/home
    mount -t btrfs -o subvol=@var,ssd,compress=zstd,discard /dev/mapper/cryptroot /mnt/var
    mount -t btrfs -o subvol=@swap,ssd,discard /dev/mapper/cryptroot /mnt/swap
    mount -t btrfs -o subvol=@nix,ssd,compress=zstd,discard /dev/mapper/cryptroot /mnt/nix

    mount /dev/"$DISK"1 /mnt/boot

# Generate swapfile
    
    VALID=no
    while [ $VALID != "yes" ]
    do
        echo "Enter swap size in GB:"
        read SWAP_SIZE
        SWAP_SIZE=$(expr $SWAP_SIZE \* 1024)
    
        echo "is $SWAP_SIZE correct? [y,n]"
        read INPUT
    
        if [ $INPUT == "y" ]; then
            VALID=yes
        fi
    done

    # TODO: also change swap size in hardware_configuration.nix accordingly

    echo "Generating Swap File ..."
    truncate -s 0 /mnt/swap/swapfile
    chattr +C /mnt/swap/swapfile
    dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count=$SWAP_SIZE status=progress
    chmod 600 /mnt/swap/swapfile
    mkswap /mnt/swap/swapfile
    swapon /mnt/swap/swapfile

    echo "Swap finished"

# Generate defualt config
    nixos-genereate-config --root /mnt

# Create diff between generated and my hardware_configuration
    diff -u /mnt/etc/bak_nixos/hardware_configuration.nix /mnt/etc/nixos/hardware_configuration.nix > hardware_configuration.patch

    echo "please remove any incorrect changes from the diff file"
    sleep 2
    vim hardware_configuration.patch

    patch -u -b /mnt/etc/bak_nixos/hardware_configuration.nix -i hardware_configuration.patch
    mv /mnt/etc/bak_nixos/hardware_configuration.nix /mnt/etc/nixos/hardware_configuration.nix

    # First, grab .nix files from repo and put them in /mnt/etc
    mv /mnt/etc/nixos /mnt/etc/bak_nixos
    mkdir /mnt/etc/nixos
    curl https://raw.githubusercontent.com/kai-gibson/dotfiles/nix/.config/nixos/configuration.nix >> /mnt/etc/nixos/configuration.nix
    curl https://raw.githubusercontent.com/kai-gibson/dotfiles/nix/.config/nixos/hardware-configuration.nix >> /mnt/etc/nixos/hardware-configuration.nix
    curl https://raw.githubusercontent.com/kai-gibson/dotfiles/nix/.config/nixos/packages.nix >> /mnt/etc/nixos/packages.nix
    
    # Then install
    cd /mnt
    #nixos-install

else
    echo "No internet detected, please connect then run the script again"
fi
