#!/bin/bash

# --- Complete script

echo "
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf
sysctl -p

echo "# --- Nginx SSL Addon --- #"
#sudo certbot certonly --manual --preferred-challenges dns
certbot --manual --preferred-challenges dns certonly -d home.cityplug.co.uk -d *.cityplug.co.uk
nginx -t
nginx -s reload

echo "# --- Enter pihole user password --- #"
docker exec -it pihole pihole -a -p
echo "#  ---  COMPLETED | REBOOT SYSTEM  ---  #"
exit


