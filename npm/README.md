cd /opt && apt update; apt install git -y 
git clone https://github.com/cityplug/pve && chmod +x pve/npm/*
------------------------------------------------------------------------------
# Run the following scripts
cd pve/npm/ && ./setup.sh