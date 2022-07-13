cd /opt && apt update; apt install git -y 
git clone https://github.com/cityplug/pve && chmod +x pve/smb/*
------------------------------------------------------------------------------
# Run the following scripts
cd pve/smb/ && ./setup.sh