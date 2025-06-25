#!/bin/bash
# 本腳本需以 root 身份執行！

echo "[INFO] 更新 apt"
sudo apt update && sudo apt upgrade -y

echo "[INFO] 安裝 wget"
sudo apt install -y wget

echo "[INFO] Docker 安裝"
wget -qO- get.docker.com | sudo bash

echo "[INFO] Docker 版本"
sudo docker -v

echo "[INFO] 設定開機自動啟動 Docker"
sudo systemctl enable docker

echo "[INFO] Docker Compose 安裝"
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

echo "[INFO] 賦權 Docker Compose"
sudo chmod +x /usr/local/bin/docker-compose

echo "[INFO] Docker Compose 版本"
sudo docker-compose --version
