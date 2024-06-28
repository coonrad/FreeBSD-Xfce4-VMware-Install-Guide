![xfce4-freebsd.jpg](xfce4-freebsd.jpg)

## FreeBSD Xfce4 on VMware Installation Guide

A guide to install the Xfce Desktop Environment on FreeBSD 14.0-RELEASE running as a guest operating system on VMware (tested on VMware Fusion 13.5.0). This guide includes configuration files and an optional configuration script.

## Requirements

* FreeBSD installed as a guest operating system on VMware.
* Installation of sudo to run install script `pkg install sudo`
* Installation of git to clone this repo `sudo pkg install git`
* Installation of bash to run install script `sudo pkg install bash`

Note: Hardware acceleration doesn't currently work with FreeBSD on VMware. The driver was [removed](https://github.com/freebsd/drm-kmod/commit/ff9d303c7ea85cd8627d0a3dc0dbccceefd30687)

## ISOs for Installing FreeBSD

* [FreeBSD-14.0-RELEASE](https://download.freebsd.org/releases/amd64/amd64/ISO-IMAGES/14.0/)
* [FreeBSD-13.2-RELEASE](https://download.freebsd.org/releases/amd64/amd64/ISO-IMAGES/13.2/)

## Quick install Xfce 4.18 and required packages

```bash
git clone https://github.com/coonrad/FreeBSD-Xfce4-VMware-Install-Guide.git
cd FreeBSD-Xfce4-VMware-Install-Guide
sudo ./xfce-install.sh
```

## Manually install Xfce 4.18 and required packages

Update the pkg repository to `latest` to install the most recent version of Xfce:

```bash
sudo mkdir -p /usr/local/etc/pkg/repos
sudo vi /usr/local/etc/pkg/repos/FreeBSD.conf
```

Add the following to `FreeBSD.conf` and run `pkg update`:

```bash
FreeBSD: {
  url: "pkg+http://pkg.FreeBSD.org/${ABI}/latest"
}
```

When you run `pkg -vv` you should see the following:

```bash
Repositories:
  FreeBSD: {
    url             : "pkg+http://pkg.FreeBSD.org/FreeBSD:14:amd64/latest",
    enabled         : yes,
    priority        : 0,
    mirror_type     : "SRV",
    signature_type  : "FINGERPRINTS",
    fingerprints    : "/usr/share/keys/pkg"
  }
```

Install `xorg` `open-vm-tools` and needed drivers:

```bash
sudo pkg install xorg open-vm-tools xf86-video-vmware xf86-input-vmmouse
```

Install Xfce (Meta-port for the Xfce Desktop Environment). This will provide a minimal Xfce Desktop Environement

```bash
sudo pkg install xfce
```

For a more complete desktop install the following additional packages to include Xfce plugins, office software, document viewer and browser:

```bash
sudo pkg install xfce4-goodies libreoffice atril firefox
```

Configure xorg to load the vmware mouse driver:

```bash
# if you haven't installed xorg yet make the directory first
sudo mkdir -p /usr/local/etc/X11/xorg.conf.d/
sudo vi /usr/local/etc/X11/xorg.conf.d/vmware.conf
```

Inclue the following configuration:

```bash
Section "ServerFlags"
       Option             "AutoAddDevices"       "false"
EndSection
Section "InputDevice"
       Identifier    "Mouse0"
       Driver        "vmmouse"
       Option        "Device"       "/dev/sysmouse"
EndSection
```

Ass your username to the video group:

```bash
sudo pw groupmod video -M $USER
```

Update `rc.conf` to start `hald` and `dbus` and `moused`:

```bash
sudo sysrc hald_enable="YES"
sudo sysrc dbus_enable="YES"
sudo sysrc moused_enable="YES"
```

Configure the kernel video output mode to `vt`:

```bash
sudo sh -c "echo kern.vty=vt >> /boot/loader.conf"
```

At this point you can start xfce with `startx` or install lightdm. For startx create an .xinitrc and reboot:

```bash
echo "exec /usr/local/bin/startxfce4 --with-ck-launch" > ~/.xinitrc
```

For lightdm install:

```bash
sudo pkg install lightdm lightdm-gtk-greeter
```

Update `rc.conf` to start lightdm:

```bash
sudo sysrc lightdm_enable="YES"
```

On vmware lightdm defaults to a display size that may not match your screen. To correct this, create a xrandr script that will be executed by lightdm to establish the correct display size. Example `/usr/local/etc/lightdm/lightdm-xrandr`:

```bash
#! /usr/local/bin/bash
xrandr --output default --primary --mode 2560x1440
```

Now update `/usr/local/etc/lightdm/lightdm.conf`:

```bash
display-setup-script=/usr/local/etc/lightdm/lightdm-xrandr
```

To enable autologin add to `lightdm.conf`:

```bash
autologin-user=<your username>
```

Reboot.
