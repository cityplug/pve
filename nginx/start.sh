#!/bin/bash

# NGINX setup script.

# Create user 
apt update && adduser shay
# Grant new user account with privileges & assign new privileges
usermod -aG sudo,adm shay && visudo
# Add the following underneath User privilege specification 
        shay	ALL=(ALL:ALL) ALL 
# Add the following to the bottom of file under includedir /etc/sudoers.d 
        shay ALL=(ALL) NOPASSWD: ALL
# Copy ssh key to server
apt install curl -y && mkdir -p /home/shay/.ssh/ && touch /home/shay/.ssh/authorized_keys
curl https://github.com/cityplug.keys >> /home/shay/.ssh/authorized_keys
# Secure SSH Server by changing default port
nano -w /etc/ssh/sshd_config
# Find the line that says '#Port 22' and change it to: 
        Port ****
# Scroll down until you find the line that says 'PermitRootLogin' and change to 'no' 
        PermitRootLogin 'no'
# Scroll down further and find 'PasswordAuthentication' and again change to 'no' 
        PasswordAuthentication 'no'
reboot

sudo su
echo "Set disable_coredump false" >> /etc/sudo.conf
# --- Install Packages
apt-get install \
    ca-certificates \
    unattended-upgrades \
    fail2ban \
    openssh-server \
    curl \
    net-tools \
    gnupg \
    lsb-release

# --- Install Docker
mkdir -p /etc/apt/keyrings && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update && apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

# --- Install Docker-Compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

systemctl enable docker
usermod -aG docker shay && docker-compose --version

# --- Install Portainer Agent & NGINX

cd /opt && nano docker-compose.yaml

------------------------------------
version: '3.0'
services:
  portainer:
    container_name: portainer_agent
    image: portainer/agent:2.11.1
    restart: always
    ports:
      - "9001:9001"
    environment:
      - TZ=Europe/London
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/lib/docker/volumes:/var/lib/docker/volumes
      - /opt/portainer:/data

  app:
    container_name: npm_app
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80' # Public HTTP Port
      - '443:443' # Public HTTPS Port
      - '81:81' # Admin Web Port
      - '21:21' # FTP
    environment:
      DB_MYSQL_HOST: "db"
      DB_MYSQL_PORT: 3306
      DB_MYSQL_USER: "shay"
      DB_MYSQL_PASSWORD: "Szxs234."
      DB_MYSQL_NAME: "npm"
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
    depends_on:
      - db

  db:
    container_name: npm_db
    image: 'jc21/mariadb-aria:latest'
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: 'T1jan331'
      MYSQL_DATABASE: 'npm'
      MYSQL_USER: 'shay'
      MYSQL_PASSWORD: 'Szxs234.'
    volumes:
      - ./data/mysql:/var/lib/mysql