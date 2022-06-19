#!/bin/bash

# --- Add shay to docker user group
usermod -aG docker shay

# --- Docker Service
docker ps
systemctl enable docker

# --- Build Homer
docker stop homer
rm -rf /srv/.AppData/homer/*
mv /home/shay/Downloads/cadmus/.scripts/homer/assets /srv/.AppData/homer/assets
docker start homer

echo "
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf
sysctl -p
echo "# --- Nginx SSL Addon --- #"
#sudo certbot certonly --manual --preferred-challenges dns
certbot -d cadmus.cityplug.co.uk --manual --preferred-challenges dns certonly
nginx -t
nginx -s reload


echo "# --- Enter pihole user password --- #"
docker exec -it pihole pihole -a -p
echo "#  ---  COMPLETED | REBOOT SYSTEM  ---  #"
exit



