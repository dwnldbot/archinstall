#!/bin/bash
timedatectl set-ntp true
sgdisk -og /dev/sda
sgdisk -n 1:2048:1050623 -t 1:ef00 /dev/sda
ENDSECTOR=`sgdisk -E /dev/sda`
sgdisk -n 2:1050624:$ENDSECTOR -t 2:8e00 /dev/sda
cryptsetup luksFormat /dev/sda2
cryptsetup luksOpen /dev/sda2 lvm
mkfs.vfat -F32 /dev/sda1
pvcreate /dev/mapper/lvm
vgcreate vg /dev/mapper/lvm
lvcreate -L 8G vg -n swap
lvcreate -L 100G vg -n root
lvcreate -l 100%FREE vg -n home
mkfs.ext4 /dev/mapper/vg-root
mkfs.ext4 /dev/mapper/vg-home
mkswap /dev/mapper/vg-swap
mount /dev/mapper/vg-root /mnt
mkdir /mnt/home
mount /dev/mapper/vg-home /mnt/home
swapon /dev/mapper/vg-swap
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

pacstrap /mnt base base-devel iw wpa_supplicant
genfstab -U /mnt >> /mnt/etc/fstab

cp ./chroot.sh /mnt/chroot.sh
arch-chroot /mnt bash chroot.sh
rm /mnt/chroot.sh

#umount -R /mnt
#reboot

