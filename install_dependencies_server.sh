#!/bin/bash
echo "Installing dependencies..."

# General update
apt-get update

# Install Docker
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io

# Docker-compose installation
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Tendermint installation
apt install -y unzip
wget https://github.com/tendermint/tendermint/releases/download/v0.31.5/tendermint_v0.31.5_linux_amd64.zip
unzip tendermint_v0.31.5_linux_amd64.zip
rm tendermint_v0.31.5_linux_amd64.zip
mv tendermint /usr/local/bin

cd /root


# Setup for SmartchainDB

echo "Starting to clone SmartchainDB..."
git clone https://github.com/sogolsmansouri/smartchaindb.git && echo "Cloned SmartchainDB." || { echo "Failed to clone SmartchainDB."; exit 1; }
cd smartchaindb || { echo "Failed to change directory to smartchaindb"; exit 1; }
rm docker-compose.yml
mv docker-compose.prod.yml docker-compose.yml


echo "Setting up environment variables..."
touch .env && echo "Created .env file." || { echo "Failed to create .env file"; exit 1; }
echo "MONGO_INITDB_ROOT_USERNAME=admin" >> .env && echo "Set MongoDB admin username."
echo "MONGO_INITDB_ROOT_PASSWORD=admin" >> .env && echo "Set MongoDB admin password."
tendermint init --home /root/.tendermint

cd ~


