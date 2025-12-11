#!/bin/bash

set -e  # Exit script if there is an error

clear

echo "[INFO] Updating apt"
sudo apt update && sudo apt upgrade -y

echo "[INFO] Installing wget"
sudo apt install -y wget

echo "[INFO] Docker installation"
wget -qO- get.docker.com | sudo bash

echo "[INFO] Docker version"
sudo docker -v

echo "[INFO] Setting Docker to start automatically on boot"
sudo systemctl enable docker

echo "[INFO] Docker Compose installation"
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

echo "[INFO] Granting permissions to Docker Compose"
sudo chmod +x /usr/local/bin/docker-compose

echo "[INFO] Docker Compose version"
sudo docker compose --version
