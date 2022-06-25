docker network create -d macvlan \
    --subnet=192.168.50.0/24 \
    --gateway=192.168.50.1 \
    -o parent=eth0 draco-01_net

sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

echo
sudo docker-compose up -d

# ----> Next Script
./finish.sh