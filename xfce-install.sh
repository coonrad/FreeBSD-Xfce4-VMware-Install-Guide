#!/usr/bin/env bash

## configure and install minimal xfce desktop environment on vmware

## check for sudo/root
if ! [ $(id -u) = 0 ]; then
  echo "This script must be run as sudo, try again..."
  exit 1
fi

## update pkg repo to 'latest' and update
mkdir -p /usr/local/etc/pkg/repos
sh -c "cat ./FreeBSD.conf >> /usr/local/etc/pkg/repos/FreeBSD.conf"
pkg update

## install vmware.conf to enable vmware mouse
mkdir -p /usr/local/etc/X11/xorg.conf.d/
sh -c "cat ./vmware.conf >> /usr/local/etc/X11/xorg.conf.d/vmware.conf"

## add username to video group
pw groupmod video -M $SUDO_USER

## update rc.conf
sysrc hald_enable="YES"
sysrc dbus_enable="YES"
sysrc moused_enable="YES"

## update /boot/loader.conf
sh -c "echo kern.vty=vt >> /boot/loader.conf"

## install .xinitrc
sh -c  'echo "exec /usr/local/bin/startxfce4 --with-ck-launch" > /home/$SUDO_USER/.xinitrc'

pkg install -y \
    xorg \
    open-vm-tools \
    xf86-video-vmware \
    xf86-input-vmmouse \
    xfce \

echo 
echo xfce install complete, please reboot and issue 'startx'
echo
