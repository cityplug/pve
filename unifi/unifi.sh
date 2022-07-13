#!/bin/bash

# Ubuntu (unifi.cityplug.co.uk) setup script.

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
# --- Initialzing unifi
hostnamectl set-hostname unifi.cityplug.co.uk
hostnamectl set-hostname "unifi" --pretty
rm -rf /etc/hosts
mv /opt/pve/unifi/hosts /etc/hosts

# --- Install Packages
echo "#  ---  Installing New Packages  ---  #"
apt install ca-certificates -y
apt install wget -y
apt install unattended-upgrades -y
apt install fail2ban -y
apt install letsencrypt -y
    
# --- Addons
echo "#  ---  Running Addons  ---  #"
rm -rf /etc/update-motd.d/* && rm -rf /etc/motd
mv /opt/pve/unifi/10-uname /etc/update-motd.d/ && chmod +x /etc/update-motd.d/10-uname
usermod -aG sudo shay
systemctl disable ssh
dpkg-reconfigure tzdata
dpkg-reconfigure --priority=low unattended-upgrades

echo "#  ---  Installing Unifi  ---  #"
wget https://get.glennr.nl/unifi/install/unifi-7.1.67.sh && bash unifi-7.1.67.sh

wget https://raw.githubusercontent.com/cityplug/pve/unifi/unifi_ssl_import.sh -O /usr/local/bin/unifi_ssl_import.sh
chmod +x /usr/local/bin/unifi_ssl_import.sh

# --- SSL
certbot -d unifi.cityplug.co.uk --manual --preferred-challenges dns certonly
sudo /usr/local/bin/unifi_ssl_import.sh

# Automate renewal script
echo "
0 * * */2 * root letsencrypt renew
5 * * */2 * root unifi_ssl_import.sh
0 0 1 * * sudo apt update && sudo apt dist-upgrade -y
0 0 1 */2 * root reboot" >>/etc/crontab
