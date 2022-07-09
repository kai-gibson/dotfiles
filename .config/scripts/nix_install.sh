#!/usr/bin/env bash

# Script to install NixOS

# Check if script is being run as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Try 'sudo bash nix_install.sh'"
    exit 0
fi

# Check if internet is connected
if nc -zw1 google.com 443; then
    # If yes, start install
    echo "Internet connected! Starting Install"
else
    echo "No internet detected, please connect before running this script"
    exit 0
fi

# Installing git
echo "Installing required tools..."

nix-env -iA nixos.git

echo -e "Done\n"

# Get disk name

lsblk
DISK_LIST=$(lsblk -l | tail -n +2 | awk '{print $1}')

echo -e "\nPlease select disk:"
echo -e "(WARNING: The selected disk will be completely wiped)\n"

VALID=no
while [ $VALID != "yes" ]
do
    select DISK in $DISK_LIST
    do
        if [ -z $(echo " $(lsblk -l | tail -n +2 | awk '{print $1}') " | grep -woP "$DISK") ]; 
        then 
            echo "Invalid input"; 
        else
            echo "is /dev/$DISK correct? [y,n]:"
            read INPUT

            if [ $INPUT == "y" ]; then
                VALID=yes
                break
            fi
        fi
    done
done

# Disk name is now stored in $DISK

# Make partitions
echo -e "\nMaking Partitions..."
echo -e "g\nn\n\n\n+500M\nt\n\n1\nn\n\n\n\np\nw\n" | fdisk /dev/$DISK
echo "Partitioning Finished"

# Encrypt disk 
VALID=no
while [ $VALID != "yes" ]
do
     echo -e "\nEnter Encryption Key:"
     read -s ENCRYPTION_KEY

     echo "Confirm Key:"
     read -s VALIDATE_ENCRYPTION_KEY


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
VALIDATE_ENCRYPTION_KEY=''

echo -e "Encryption Successful\n"

# Make Filesystem
echo -e "Making Filesystem and Mounting Disks...\n"
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
    echo -e "\nEnter swap size in GB:"
    read SWAP_SIZE
    SWAP_SIZE=$(expr $SWAP_SIZE \* 1024)

    echo "is "$SWAP_SIZE"MB correct? [y,n]"
    read INPUT

    if [ $INPUT == "y" ]; then
        VALID=yes
    fi
done

echo -e "\nGenerating Swap File ...\n"
truncate -s 0 /mnt/swap/swapfile
chattr +C /mnt/swap/swapfile
dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count=$SWAP_SIZE status=progress
chmod 600 /mnt/swap/swapfile
mkswap /mnt/swap/swapfile
swapon /mnt/swap/swapfile

echo -e "\nSwap finished"

# Generate defualt config
nixos-generate-config --root /mnt

# Grab my .nix files from github and put them in /mnt/etc
mv /mnt/etc/nixos /mnt/etc/bak_nixos
mkdir /mnt/etc/nixos
curl https://raw.githubusercontent.com/kai-gibson/dotfiles/nix/.config/nixos/configuration.nix > /mnt/etc/nixos/configuration.nix
curl https://raw.githubusercontent.com/kai-gibson/dotfiles/nix/.config/nixos/hardware-configuration.nix > /mnt/etc/nixos/hardware-configuration.nix
curl https://raw.githubusercontent.com/kai-gibson/dotfiles/nix/.config/nixos/packages.nix > /mnt/etc/nixos/packages.nix

HW_CONFIG_OLD=/mnt/etc/bak_nixos/hardware-configuration.nix
HW_CONFIG_NEW=/mnt/etc/nixos/hardware-configuration.nix

# Add user entered swap value to hardware-configuration.nix
# NOT WORKING TODO
#cat /mnt/etc/nixos/hardware-configuration.nix | sed "s/size = (1024 \* 8);/size = $SWAP_SIZE;/g" > /mnt/etc/nixos/hardware-configuration.nix

# Create diff between generated and my hardware-configuration
diff -u $HW_CONFIG_OLD $HW_CONFIG_NEW > patch

chmod +rw patch

echo -e "\nplease remove any incorrect changes from the diff file"
sleep 2

vim -s patch patch

patch -u -b $HW_CONFIG_OLD -i patch
mv $HW_CONFIG_NEW /mnt/etc/bak_nixos/new_hardware-configuration.nix
mv $HW_CONFIG_OLD /mnt/etc/nixos/hardware-configuration.nix

# List out mounts, btrfs subvols, /mnt discard
# Prompt to edit config

echo -e "\nPatching complete\n"
echo -e "Anything else before install?\n"

DONE=no
while [ $DONE != "yes" ]
do
    echo -e "  1) List mounts, subvolumes, and DIR's on /mnt"
    echo -e "  2) Edit configuration.nix"
    echo -e "  3) Edit hardware-configuration.nix"
    echo -e "  4) Cancel install process (or finish install manually)"
    echo -e "  5) Done, run installer now"
    read INPUT

    case $INPUT in
        1)
            rm out
            echo -e "\nMount points:\n" >> out
            mount | grep /mnt >> out
            echo -e "\n/mnt contents:\n" >> out
            ls /mnt >> out
            echo -e "\nBtrfs subvolumes:\n" >> out
            btrfs subvol list /mnt >> out
            
            less out
        ;;
        2)
            vim -s /mnt/etc/nixos/configuration.nix /mnt/etc/nixos/configuration.nix 
        ;;
        3)
            vim -s /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/hardware-configuration.nix 
        ;;
        4)
            exit 0
        ;;
        5)
            DONE=yes
        ;;
        *)
            echo -e "\n Invalid option, try again:\n"
        ;;
    esac
done

# Then install
cd /mnt
nixos-install
