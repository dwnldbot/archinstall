#!/bin/bash

ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "broken" > /etc/hostname

sed -i 's/modconf block filesystems/modconf block encrypt lvm2 filesystems/g' /etc/mkinitcpio.conf
mkinitcpio -p linux
passwd

bootctl --path=/boot install

echo -e '# timeout 0\ndefault arch' > /boot/loader/loader.conf
echo -e 'title\tArch Linux\nlinux\t\vmlinuz-linux\ninitrd\t/initramfs-linux.img\noptions\tcryptdevice=/dev/sda2:lvm root=/dev/mapper/vg-root resume=/dev/mapper/vg-swap quiet rw' > /boot/loader/entries/arch.conf
