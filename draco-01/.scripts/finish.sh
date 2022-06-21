#!/bin/bash

# --- Add shay to docker user group
usermod -aG docker shay

# --- Docker Service
docker ps
systemctl enable docker

echo "
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf
sysctl -p

echo "# --- Nginx SSL Addon --- #"
#sudo certbot certonly --manual --preferred-challenges dns
certbot --manual --preferred-challenges dns certonly -d home.cityplug.co.uk
nginx -t
nginx -s reload

echo "#  ---  COMPLETED | REBOOT SYSTEM  ---  #"
reboot



