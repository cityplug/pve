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
# --- Initialzing nginx
hostnamectl set-hostname nginx.home.lan
hostnamectl set-hostname "nginx" --pretty
rm -rf /etc/hosts
mv /opt/pve/smb/hosts /etc/hosts

# --- Install Packages
echo "#  ---  Installing New Packages  ---  #"
apt install unattended-upgrades -y
apt install fail2ban -y
# --- Install Docker
mkdir -p /etc/apt/keyrings && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update && apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

# --- Install Docker-Compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

systemctl enable docker
usermod -aG docker shay && docker-compose --version

# --- Addons
echo "#  ---  Running Addons  ---  #"
rm -rf /etc/update-motd.d/* && rm -rf /etc/motd
mv /opt/pve/smb/10-uname /etc/update-motd.d/ && chmod +x /etc/update-motd.d/10-uname
usermod -aG sudo shay
systemctl disable ssh

mkdir -p /draco

dpkg-reconfigure tzdata
timedatectl set-ntp true
timedatectl set-local-rtc 0

# --- Auto Service
(crontab -l 2>/dev/null; echo "*/30 * * * * sudo systemctl restart ssh.service") | crontab -

echo "#  ---  REBOOTING  ---  #"
reboot