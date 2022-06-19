#!/bin/bash

# Raspbian (cadmus.machine v2) setup script.

# --- Remove Bloatware
echo "#  ---  Removing Bloatware  ---  #"
apt update && apt dist-upgrade -y
apt-get autoremove && apt-get autoclean -y
rm -rf python_games && rm -rf /usr/games/
apt-get purge --auto-remove libraspberrypi-dev libraspberrypi-doc -y

# --- Disable Services
echo "#  ---  Disabling Bloatware Services  ---  #"
systemctl stop alsa-state.service hciuart.service sys-kernel-debug.mount \
systemd-udev-trigger.service rpi-eeprom-update.service systemd-journald.service \
systemd-fsck-root.service systemd-logind.service wpa_supplicant.service \
bluetooth.service apt-daily.service apt-daily.timer apt-daily-upgrade.timer apt-daily-upgrade.service

systemctl disable alsa-state.service hciuart.service sys-kernel-debug.mount \
systemd-udev-trigger.service rpi-eeprom-update.service systemd-journald.service \
systemd-fsck-root.service systemd-logind.service wpa_supplicant.service \
bluetooth.service apt-daily.service apt-daily.timer apt-daily-upgrade.timer apt-daily-upgrade.service

# --- Over clcok raspberry pi & increase GPU
sed -i '40i\over_voltage=2\narm_freq=1750\n' /boot/config.txt

# --- Disable Bluetooth & Wifi
echo "
disable_splash=1
dtoverlay=disable-wifi
dtoverlay=disable-bt" >> /boot/config.txt

# --- Change root password
echo "#  ---  Change root password  ---  #"
passwd root
echo "#  ---  Root password changed  ---  #"

# --- Initialzing cadmus
hostnamectl set-hostname cadmus.local
hostnamectl set-hostname "cadmus-tinypi" --pretty
rm -rf /etc/hosts
mv /home/shay/Downloads/cadmus/.scripts/hosts /etc/hosts

# --- Install Packages
echo "#  ---  Installing New Packages  ---  #"
apt install unattended-upgrades; apt install fail2ban -y
apt install cockpit; apt install cockpit-pcp -y
apt-get install samba samba-common-bin -y
echo "#  ---  Installing docker  ---  #"
curl -sSL https://get.docker.com | sh
apt install docker-compose -y && docker-compose version

# --- Addons
echo "#  ---  Running Addons  ---  #"
mkdir -p /srv/.AppData/
mkdir -p /srv/storage/ && chown -R shay:shay /srv/storage/

rm -rf /etc/update-motd.d/* && rm -rf /etc/motd
rm -rf /etc/issue.d/cockpit.issue /etc/motd.d/cockpit
mv /home/shay/Downloads/cadmus/10-uname /etc/update-motd.d/ && chmod +x /etc/update-motd.d/10-uname

mv /home/shay/Downloads/cadmus/.scripts/ssh_config /home/shay/.ssh/config

# --- Backup Script
(crontab -l 2>/dev/null; echo "0 1 * * * /home/shay/Downloads/cadmus/.scripts/backup.sh") | crontab -

# --- Create and allocate swap
echo "#  ---  Creating 4GB swap file  ---  #"
fallocate -l 4G /swapfile
# --- Sets permissions on swap
chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
# --- Add swap to the /fstab file
sh -c 'echo "/swapfile none swap sw 0 0" >> /etc/fstab'
# --- Verify command
cat /etc/fstab
# --- Clear older versions
sh -c 'echo "apt autoremove -y" >> /etc/cron.monthly/autoremove'
# --- Make file executable
chmod +x /etc/cron.monthly/autoremove
echo "#  ---  4GB swap file created | SYSTEM REBOOTING  ---  #"

reboot

# ----> Next Script | security-samba.sh