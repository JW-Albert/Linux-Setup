#!/bin/bash
# 本腳本需以 root 執行！

echo "[INFO] 安裝 ufw（Uncomplicated Firewall）"
apt update
apt install ufw -y

echo "[INFO] 設定預設防火牆規則：拒絕所有輸入、允許輸出"
ufw default deny incoming
ufw default allow outgoing

echo "[INFO] 開放 TCP port 55555"
ufw allow 55555/tcp

echo "[INFO] 啟用 ufw 防火牆"
ufw --force enable

echo "[INFO] 備份 before.rules"
cp /etc/ufw/before.rules /etc/ufw/before.rules.bak.$(date +%s)

echo "[INFO] 修改 ICMP 規則為 DROP"
# 使用 sed 直接取代 ICMP 設定為 DROP
sed -i '/-A ufw-before-input -p icmp --icmp-type destination-unreachable/s/ACCEPT/DROP/' /etc/ufw/before.rules
sed -i '/-A ufw-before-input -p icmp --icmp-type time-exceeded/s/ACCEPT/DROP/' /etc/ufw/before.rules
sed -i '/-A ufw-before-input -p icmp --icmp-type parameter-problem/s/ACCEPT/DROP/' /etc/ufw/before.rules
sed -i '/-A ufw-before-input -p icmp --icmp-type echo-request/s/ACCEPT/DROP/' /etc/ufw/before.rules

echo "[INFO] 重新載入 ufw 防火牆規則"
ufw reload

echo "[INFO] 所有設定已完成"
