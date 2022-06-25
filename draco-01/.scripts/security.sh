#!/bin/bash

# --- Secure Fail2Ban
echo "#  ---  Securing fail2ban --- #"
mv /opt/pve/draco-01/.scripts/jail.local /etc/fail2ban/jail.local
systemctl restart fail2ban

# --- Addons
groupadd ssh-users
usermod -aG ssh-users shay
sed -i '15i\AllowGroups ssh-users\n' /etc/ssh/sshd_config

# ----> Next Script
./draco_net.sh