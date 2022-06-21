#!/bin/bash

# Raspbian (draco-01.machine v2) setup script.

# --- Remove Bloatware
echo "#  ---  Removing Bloatware  ---  #"
apt update && apt dist-upgrade -y
apt-get autoremove && apt-get autoclean -y
rm -rf python_games && rm -rf /usr/games/

# --- Disable Services
echo "#  ---  Disabling Bloatware Services  ---  #"
systemctl stop alsa-state.service sys-kernel-debug.mount \
systemd-udev-trigger.service systemd-journald.service \
systemd-fsck-root.service systemd-logind.service wpa_supplicant.service \
bluetooth.service apt-daily.service apt-daily.timer apt-daily-upgrade.timer apt-daily-upgrade.service

systemctl disable alsa-state.service sys-kernel-debug.mount \
systemd-udev-trigger.service systemd-journald.service \
systemd-fsck-root.service systemd-logind.service wpa_supplicant.service \
bluetooth.service apt-daily.service apt-daily.timer apt-daily-upgrade.timer apt-daily-upgrade.service

# --- Change root password
echo "#  ---  Change root password  ---  #"
passwd root
echo "#  ---  Root password changed  ---  #"

# --- Initialzing draco-01
hostnamectl set-hostname draco-01.home.lan
hostnamectl set-hostname "draco-01" --pretty
rm -rf /etc/hosts
mv /opt/pve/draco-01/.scripts/hosts /etc/hosts

# --- Install Packages
echo "#  ---  Installing New Packages  ---  #"
apt install unattended-upgrades -y
apt install netdiscover -y
apt install fail2ban -y
apt install cockpit -y
apt install cockpit-pcp -y
echo "#  ---  Installing nginx  ---  #"
apt install nginx; apt install python3-certbot-nginx -y
echo "#  ---  Installing docker  ---  #"
curl -sSL https://get.docker.com | sh
apt install docker-compose -y && docker-compose version

# --- Addons
echo "#  ---  Running Addons  ---  #"
mkdir -p /srv/.AppData/

echo "
disable_splash=1" >> /boot/config.txt

rm -rf /etc/update-motd.d/* && rm -rf /etc/motd
rm -rf /etc/issue.d/cockpit.issue /etc/motd.d/cockpit
mv /opt/pve/draco-01/10-uname /etc/update-motd.d/ && chmod +x /etc/update-motd.d/10-uname

mv /opt/pve/draco-01/.scripts/ssh_config /home/shay/.ssh/config
reboot

# ----> Next Script | security.sh