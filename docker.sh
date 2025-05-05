#!/bin/bash
# 本腳本需以 root 身份執行！

echo "[INFO] 更新 apt"
apt update -y && apt upgrade -y

echo "[INFO] 安裝 wget vim"
apt install -y wget vim

echo "[INFO] Docker 安裝"
wget -qO- get.docker.com | bash

echo "[INFO] Docker 版本"
docker -v

echo "[INFO] 設定開機自動啟動 Docker"
systemctl enable docker

echo "[INFO] Docker Compose 安裝"
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

echo "[INFO] 賦權 Docker Compose"
chmod +x /usr/local/bin/docker-compose

echo "[INFO] Docker Compose 版本"
docker-compose --version
