# Run the following scripts
cd /opt && apt update; apt install git -y 
git clone https://github.com/cityplug/pve && chmod +x pve/unifi/* && cd pve/unifi/ && ./unifi.sh
------------------------------------------------------------------------------
# SSL
certbot -d unifi.cityplug.co.uk --manual --preferred-challenges dns certonly
sudo /usr/local/bin/unifi_ssl_import.sh
------------------------------------------------------------------------------
# ln -s /usr/local/bin/unifi_ssl_import.sh /etc/letsencrypt/renewal-hooks/deploy/01-unifi_ssl_import


