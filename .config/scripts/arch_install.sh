#!/usr/bin/env bash

# Script to automate my Arch installation

# Check if script is being run as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Try 'sudo bash arch_install.sh'"
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
         fzf
         lf
         lazygit
         thunar
         kitty
         zsh
         git
         tmux
         feh
         picom
         udiskie
         bat
         ripgrep
         fd
         trash-cli
         ueberzug
         p7zip
         nodejs
         gdb
         xorg
         xorg-xinit
         plymouth
         pipewire
         pipewire-pulse
         wireplumber
         qpwgraph
         pipewire-audio
         pipewire-jack
         pipewire-alsa
         "

#TODO Graphics drivers?
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

# setup user
CHROOT_CMD="useradd -m kai
            echo kai:$USER_PASS | chpasswd -c DES
            echo root:$USER_PASS | chpasswd -c DES
            "
sed -i '/root ALL=(ALL:ALL) ALL/a\kai ALL=(ALL:ALL) ALL' /mnt/etc/sudoers

arch-chroot /mnt /bin/bash -c "$CHROOT_CMD"

# Setup tty autologin
arch-chroot /mnt /bin/bash -c "mkdir -p /etc/systemd/system/getty@tty1.service.d/"
arch-chroot /mnt /bin/bash -c "echo -e '[Service]\nExecStart=\nExecStart=/sbin/agetty --skip-login --autologin kai --noclear %I 38400 linux' > /etc/systemd/system/getty@tty1.service.d/override.conf"
arch-chroot /mnt /bin/bash -c "systemctl enable getty@tty1"

# Link nvim to vim
arch-chroot /mnt /bin/bash -c "ln -sf /bin/nvim /bin/vim"

# Plymouth setup
echo -e "[Daemon]\nTheme=bgrt" > /mnt/etc/plymouthd.conf

# Install paru -- this doesn't work because makepkg asks for a sudo password we can't give it
#PARU_CMD="cd ~ 
#          git clone https://aur.archlinux.org/paru.git
#          cd paru
#          makepkg -si
#          cd ..
#          echo $USER_PASS | sudo -S rm -rf paru
#         "
#
#arch-chroot /mnt /bin/bash -c "su kai --command='$PARU_CMD'"
#
# Install AUR packages -- will this prompt me?
#AUR_PKGS="brave-bin
#nordic-darker-theme
#qt5-styleplugins
#tela-icon-theme
#"

#arch-chroot /mnt /bin/bash -c "su kai --command='echo $AUR_PKGS | paru -S -'"

# Audio setup
arch-chroot /mnt /bin/bash -c "su kai --command='systemctl --user enable pipewire-pulse'"

# Setup dotfiles
GITCMD='
    rm -rf /home/kai/.*
    rm -rf /home/kai/*
    echo ".dotfiles" >> /home/kai/.gitignore 
    git clone --bare https://github.com/kai-gibson/dotfiles.git /home/kai/.dotfiles 
    git --git-dir=/home/kai/.dotfiles --work-tree=/home/kai checkout
    '

arch-chroot /mnt /bin/bash -c "su kai --command='$GITCMD'"

# Setup vim-plug
VIMCMD='curl -fLo /home/kai/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    '
arch-chroot /mnt /bin/bash -c "su kai --command='$VIMCMD'"

arch-chroot /mnt /bin/bash -c "su kai --command='git clone https://github.com/kai-gibson/kwm.git /home/kai/.config/kwm'"

# build suckless suite
SUCKLESS_MAKE='cd /home/kai/.config/kwm
    make clean install

    cd ../dmenu-kai
    make clean install

    cd ../dwmblocks-kai
    make clean install

    cd ../st-kai
    make clean install
    '

arch-chroot /mnt /bin/bash -c "$SUCKLESS_MAKE"

# Install bootloader
arch-chroot /mnt /bin/bash -c "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB"

UUID=$(ls -l /dev/disk/by-uuid | grep $DISK | perl -ne '/.*\d+:\d+\s+(\S*)\s+.*2$/ && print "$1\n"')

export GRUB_ARGS="loglevel=3 quiet splash rd.udev.log_priority=3 vt.global_cursor_default=0 cryptdevice=UUID=${UUID}:cryptroot root=/dev/mapper/cryptroot"

perl -pi.bak -e 's/(GRUB_CMDLINE_LINUX_DEFAULT=).*/$1\"$ENV{GRUB_ARGS}\"/' /mnt/etc/default/grub

perl -pi.bak -e 's/(MODULES=).*/$1(i915 btrfs)/' /mnt/etc/mkinitcpio.conf
perl -pi.bak -e 's/(HOOKS=).*/$1(base plymouth udev autodetect modconf kms keyboard keymap consolefont block encrypt filesystems fsck)/' /mnt/etc/mkinitcpio.conf # TODO add plymouth?

arch-chroot /mnt /bin/bash -c "mkinitcpio -p linux"
arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"

echo -e "\n\nDone! Reboot when ready"

##TODO:
# - install paru
