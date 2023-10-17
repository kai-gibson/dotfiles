#!/usr/bin/env bash

# Script to automate my Arch installation

# Check if script is being run as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Try 'sudo bash arch_install.sh'"
    exit 0
fi

# Check if internet is connected
if nc -zw1 google.com 443; then # If yes, start install echo "Internet connected! Starting Install"
else
    echo "No internet detected, please connect before running this script"
    exit 0
fi

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
        if [ -z $(echo "$(lsblk -l | tail -n +2 | awk '{print $1}')" | grep -woP "$DISK") ]; 
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
echo -e "g\nn\n\n\n+500M\nt\n\n1\nn\n\n\n\np\nw\n" | fdisk /dev/$DISK > /dev/null
fdisk /dev/$DISK -l
echo -e "\nPartitioning Finished"

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
mkfs.vfat /dev/"$DISK"1 > /dev/null
mkfs.btrfs /dev/mapper/cryptroot > /dev/null
mount /dev/mapper/cryptroot /mnt > /dev/null
btrfs subvol create /mnt/@ > /dev/null
btrfs subvol create /mnt/@home > /dev/null
btrfs subvol create /mnt/@var > /dev/null
btrfs subvol create /mnt/@swap > /dev/null
lsblk

# Mount Subvolumes and Partitions
umount /mnt
mount -t btrfs -o subvol=@,ssd,compress=zstd,discard /dev/mapper/cryptroot /mnt
mkdir /mnt/{boot,home,var,swap}

mount -t btrfs -o subvol=@home,ssd,compress=zstd,discard /dev/mapper/cryptroot /mnt/home
mount -t btrfs -o subvol=@var,ssd,compress=zstd,discard /dev/mapper/cryptroot /mnt/var
mount -t btrfs -o subvol=@swap,ssd /dev/mapper/cryptroot /mnt/swap

mount /dev/"$DISK"1 /mnt/boot

# Generate swapfile
VALID=no
while [ $VALID != "yes" ]
do
    echo -e "\nEnter swap size in GB:"
    read SWAP_SIZE
    SWAP_SIZE=$(expr $SWAP_SIZE \* 1024)

    echo "is "$SWAP_SIZE" MB correct? [y,n]"
    read INPUT

    if [ $INPUT == "y" ]; then
        VALID=yes
    fi
done

echo -e "\nGenerating Swap File ...\n"
truncate -s 0 /mnt/swap/swapfile
chattr +C /mnt/swap/swapfile
#btrfs property set /mnt/swap/swapfile compression none
dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count=$SWAP_SIZE status=progress
chmod 600 /mnt/swap/swapfile

mkswap /mnt/swap/swapfile
swapon /mnt/swap/swapfile

echo -e "\nSwap creation finished"

# Get swap device size if I want to hibernate?

echo -e "\nInstalling essential packages"
# Install essential packages

reflector > /etc/pacman.d/mirrorlist
PACSTRAP="linux 
         linux-firmware
         base
         base-devel
         neovim
         iwd
         dhcpcd 
         networkmanager 
         man-db 
         btrfs-progs 
         grub 
         grub-btrfs 
         efibootmgr
         intel-ucode
         "

pacstrap -K /mnt $PACSTRAP

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Enter into chroot, setup timezone & localisation
CHROOT_CMD="ln -sf /usr/share/zoneinfo/Australia/Melbourne /etc/localtime
            hwclock --systohc
            sed -i '/en_AU.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
            locale-gen
            echo 'arch' > /etc/hostname
            "
arch-chroot /mnt /bin/bash -c "$CHROOT_CMD"

# Chroot create user kai, do some setup

# Set user password  
VALID=no
while [ $VALID != "yes" ]
do
     echo -e "\nEnter password for kai:"
     read -s USER_PASS

     echo "Confirm Key:"
     read -s VALIDATE_USER_PASS

     if [ $USER_PASS == $VALIDATE_USER_PASS ]; then
         VALID=yes
     else
         echo "Passwords don't match, please try again"
     fi
done 

CHROOT_CMD="useradd -m kai
            echo kai:$USER_PASS | chpasswd -c DES
            echo root:$USER_PASS | chpasswd -c DES
            "
sed -i '/root ALL=(ALL:ALL) ALL/a\kai ALL=(ALL:ALL) ALL' /mnt/etc/sudoers

arch-chroot /mnt /bin/bash -c "su - -c $CHROOT_CMD"

arch-chroot /mnt /bin/bash -c "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB"

DISK="$DISK"2
UUID=$(ls -l /dev/disk/by-uuid | grep $DISK | perl -ne '/\S+-\S+-\S+-\S+-\S+/ && print "$&\n"')

export GRUB_ARGS='"loglevel=3 quiet splash rd.udev.log_priority=3 vt.global_cursor_default=0 cryptdevice=UUID=${UUID}:cryptroot root=/dev/mapper/cryptroot"'
perl -pi.bak -e 's/(GRUB_CMDLINE_LINUX_DEFAULT=).*/$1$ENV{GRUB_ARGS}/' /mnt/etc/default/grub

perl -pi.bak -e 's/(MODULES=).*/$1(i915 btrfs)/' /mnt/etc/mkinitcpio.conf
perl -pi.bak -e 's/(HOOKS=).*/$1(base udev plymouth autodetect modconf kms keyboard keymap consolefont block encrypt filesystems fsck)/' /mnt/etc/mkinitcpio.conf

arch-chroot /mnt /bin/bash -c "mkinitcpio -p linux"

arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"

#"loglevel=3 quiet splash rd.udev.log_priority=3 vt.global_cursor_default=0 cryptdevice=UUID=e5b0f14d-65d5-41c5-847b-5ed949f88c29:cryptroot root=/dev/mapper/cryptroot"
# Home setup for user

# Set up bootloader
#"loglevel=3 quiet splash rd.udev.log_priority=3 vt.global_cursor_default=0 cryptdevice=UUID=e5b0f14d-65d5-41c5-847b-5ed949f88c29:cryptroot root=/dev/mapper/cryptroot"
# Add kernel modules

## Finally, enter into install and setup doftiles and password for user kai
#
#
#echo "kai:$USER_PASS" | nixos-enter --root '/mnt' --command 'chpasswd'
#
## Setup dotfiles
#
#GITCMD='su kai --command sh\n
#    rm -rf ~/.*\n
#    rm -rf ~/*\n
#    echo ".dotfiles" >> ~/.gitignore\n 
#    git clone --bare -b nix 
#    https://github.com/kai-gibson/dotfiles.git $HOME/.dotfiles\n 
#    git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout\n
#    exit\nexit\n'
#
#echo -e $GITCMD | nixos-enter --root '/mnt'
#
## Setup vim-plug
#
#VIMCMD='su kai --command sh\n
#    curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs 
#    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim\n
#    exit\nexit\n'
#
#echo -e $VIMCMD | nixos-enter --root '/mnt'
#
## Install the bootloader and generate mkinitcpio
#
#
## Done! Prompt to reboot
#
#VALID=no
#while [ $VALID != "yes" ]
#do
#    echo -e "\nInstallation finished, reboot now? [y/n]"
#    read INPUT
#
#    if [ $INPUT == "y" ]; then
#        VALID=yes
#    else
#        exit 0
#    fi
#done
#
#reboot
