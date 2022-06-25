#!/bin/bash

sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

echo
sudo docker-compose up -d

echo "
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf
sysctl -p

echo "# --- Enter pihole user password --- #"
docker exec -it pihole pihole -a -p
echo "#  ---  COMPLETED | REBOOT SYSTEM  ---  #"
exit


