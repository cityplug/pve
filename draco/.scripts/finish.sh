#!/bin/bash

sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

echo
sudo docker-compose up -d

# --- Docker Service
docker ps

# --- Build Homer
docker stop homer
rm -rf /draco/.AppData/homer/*
mv /opt/pve/draco/.scripts/homer/assets /draco/.AppData/homer/assets
docker start homer

echo "
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf
sysctl -p

echo "# --- Enter pihole user password --- #"
docker exec -it pihole_vm pihole -a -p
echo "#  ---  COMPLETED | REBOOT SYSTEM  ---  #"
exit


