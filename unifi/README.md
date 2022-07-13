cd /opt && apt update; apt install git -y 
git clone https://github.com/cityplug/pve && chmod +x pve/unifi/*
------------------------------------------------------------------------------
# Run the following scripts
cd pve/unifi/ && ./unifi.sh
------------------------------------------------------------------------------
certbot -d unifi.cityplug.co.uk --manual --preferred-challenges dns certonly
	Select option 1
	Enter email address
	Enter unifi domain
reboot
------------------------------------------------------------------------------
	 


