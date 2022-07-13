#!/bin/bash

# Raspbian (draco file server v1) setup script.

# --- Remove Bloatware
echo "#  ---  Removing Bloatware  ---  #"
apt update && apt dist-upgrade -y
apt-get autoremove && apt-get autoclean -y

# --- Disable Services
echo "#  ---  Disabling Bloatware Services  ---  #"
systemctl stop sys-kernel-debug.mount \
systemd-udev-trigger.service systemd-journald.service \
systemd-fsck-root.service systemd-logind.service \
apt-daily.service apt-daily.timer apt-daily-upgrade.timer apt-daily-upgrade.service

systemctl disable sys-kernel-debug.mount \
systemd-udev-trigger.service systemd-journald.service \
systemd-fsck-root.service systemd-logind.service \
apt-daily.service apt-daily.timer apt-daily-upgrade.timer apt-daily-upgrade.service

# --- Change root password
echo "#  ---  Change root password  ---  #"
passwd root
echo "#  ---  Root password changed  ---  #"
adduser shay
# --- Initialzing draco-smb
hostnamectl set-hostname draco-smb.home.lan
hostnamectl set-hostname "draco file server" --pretty
rm -rf /etc/hosts
mv /opt/pve/smb/hosts /etc/hosts

# --- Install Packages
echo "#  ---  Installing New Packages  ---  #"
apt install unattended-upgrades -y
apt install fail2ban -y
# --- Install Samba
apt install samba -y

# --- Addons
echo "#  ---  Running Addons  ---  #"
rm -rf /etc/update-motd.d/* && rm -rf /etc/motd
mv /opt/pve/smb/10-uname /etc/update-motd.d/ && chmod +x /etc/update-motd.d/10-uname
usermod -aG sudo shay
systemctl disable ssh

mkdir -p /draco
mkdir /draco/storage
mkdir /draco/public
mkdir /draco/backups

# --- Setup samba share and config
echo "#  ---  Setting up samba share --- #"
addgroup sambashare
usermod -aG sambashare shay

chown -R shay:sambashare /draco/*
#chmod -R 777 /draco/storage
#chmod -R 777 /draco/public
#chmod -R 777 /draco/backups
chmod -R 777 /draco/*

systemctl stop smbd
mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
mv /opt/pve/smb/smb.conf /etc/samba/
echo "#  ---  Create samba user password --- #"
smbpasswd -a shay
echo
/etc/init.d/smbd restart
/etc/init.d/nmbd restart

# --- Secure UFW
ufw allow samba
ufw limit ssh
ufw enable

echo "#  ---  REBOOTING  ---  #"
reboot