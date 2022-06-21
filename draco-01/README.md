# Create new user
sudo adduser shay
# Grant new user account with privileges & assign new privileges
sudo usermod -aG sudo,adm shay && sudo visudo
# Add the following underneath User privilege specification 
    shay	ALL=(ALL:ALL) ALL 
# Add the following to the bottom of file under includedir /etc/sudoers.d 
    shay ALL=(ALL) NOPASSWD: ALL
# Copy ssh key to server
sudo su
mkdir -p /home/shay/.ssh/ && touch /home/shay/.ssh/authorized_keys
curl https://github.com/cityplug.keys >> /home/shay/.ssh/authorized_keys
#Secure SSH Server by changing default port
nano -w /etc/ssh/sshd_config
    Find the line that says “#Port 22” and change it to: 
    Port ****
# Scroll down until you find the line that says “PermitRootLogin” and change to “no” 
    PermitRootLogin “no”
# Scroll down further and find “PasswordAuthentication” and again change to “no” 
    PasswordAuthentication “no”
--------------------------------------------------------------------------------
sudo su
cd /opt
apt install git -y && git clone https://github.com/cityplug/pve && chmod +x pve/draco-01/.scripts/*
------------------------------------------------------------------------------
Run the following scripts
cd pve/draco-01/.scripts/ && ./start.sh
sudo su
cd opt/pve/draco-01/.scripts/ && ./security.sh
--------------------------------------------------------------------------------
# echo "
# interface eth0
# static ip_address=192.168.50.250/24
# static routers=192.168.50.1" >> /etc/dhcpcd.conf