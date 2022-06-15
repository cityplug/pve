#!/bin/bash

# Ubuntu (unifi.cityplug.co.uk) setup script.

# Create user 
apt update && adduser shay
# Grant new user account with privileges & assign new privileges
usermod -aG sudo,adm,ssh shay && visudo
# Add the following underneath User privilege specification 
        shay	ALL=(ALL:ALL) ALL 
# Add the following to the bottom of file under includedir /etc/sudoers.d 
        shay ALL=(ALL) NOPASSWD: ALL
# Copy ssh key to server
apt install curl -y && mkdir -p /home/shay/.ssh/ && touch /home/shay/.ssh/authorized_keys
curl https://github.com/cityplug.keys >> /home/shay/.ssh/authorized_keys
# Secure SSH Server by changing default port
nano -w /etc/ssh/sshd_config
# Find the line that says “#Port 22” and change it to: 
        Port ****
# Scroll down until you find the line that says “PermitRootLogin” and change to “no” 
        PermitRootLogin “no”
# Scroll down further and find “PasswordAuthentication” and again change to “no” 
        PasswordAuthentication “no”
reboot

sudo su
echo "Set disable_coredump false" >> /etc/sudo.conf
# --- Install Packages
apt-get install \
    ca-certificates \
    wget \
    unattended-upgrades \
    fail2ban \
    openssh-server \
    letsencrypt \
    lsb-release
    
wget https://get.glennr.nl/unifi/install/unifi-7.1.66.sh && bash unifi-7.1.66.sh

# Request certificate from Letsencrypt
certbot -d unifi.cityplug.co.uk --manual --preferred-challenges dns certonly

wget https://raw.githubusercontent.com/cityplug/odin/main/unifi_ssl_import.sh -O /usr/local/bin/unifi_ssl_import.sh
# comment changes the red-hot lines and uncomment the detain ubuntu lines and set your host name unifi.yourdomain.com
nano -w /usr/local/bin/unifi_ssl_import.sh
                Change LE_MODE to yes
                service unifi status
# Automate renewal script
echo "
0 * * */2 * root letsencrypt renew
5 * * */2 * root unifi_ssl_import.sh" >>/etc/crontab
