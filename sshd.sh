#!/bin/bash
# 本腳本需以 root 身份執行

echo "[INFO] 備份 sshd_config"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%s)

echo "[INFO] 設定 Port 為 55555"
# 移除原本的 Port 行（若存在）
sed -i '/^#\?Port /d' /etc/ssh/sshd_config
# 新增設定
echo "Port 55555" >> /etc/ssh/sshd_config

echo "[INFO] 禁止 root 登入"
# 移除原本的 PermitRootLogin 行（若存在）
sed -i '/^#\?PermitRootLogin /d' /etc/ssh/sshd_config
# 新增設定
echo "PermitRootLogin no" >> /etc/ssh/sshd_config

echo "[INFO] 重新啟動 SSH 服務"
systemctl restart ssh

echo "[INFO] SSH 設定已完成，請使用 port 55555 登入"
