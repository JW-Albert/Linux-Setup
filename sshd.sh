#!/bin/bash
# 本腳本需以 root 身份執行

echo "[SETUP] 備份 sshd_config..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%s)

# === 1. 讀取 SSH Port ===
read -p "[INPUT] 請輸入新的 SSH Port（預設為 55555）: " ssh_port
ssh_port=${ssh_port:-55555}
echo "[INFO] 設定 SSH Port 為 $ssh_port"

# 修改 SSH Port
sed -i '/^#\?Port /d' /etc/ssh/sshd_config
echo "Port $ssh_port" >> /etc/ssh/sshd_config

# === 2. 是否允許 root 登入 ===
read -p "[INPUT] 是否允許 root 使用 SSH 登入？(yes/no，預設 no): " allow_root
allow_root=${allow_root:-no}
echo "[INFO] 設定 PermitRootLogin 為 $allow_root"

# 修改 root 登入設定
sed -i '/^#\?PermitRootLogin /d' /etc/ssh/sshd_config
echo "PermitRootLogin $allow_root" >> /etc/ssh/sshd_config

# === 3. 啟用 port 80 與 443？ ===
read -p "[INPUT] 是否開放 port 80？(y/N): " open_80
read -p "[INPUT] 是否開放 port 443？(y/N): " open_443

# 開放 port (若有 ufw)
if command -v ufw &> /dev/null; then
  echo "[INFO] 設定 ufw 防火牆..."
  ufw allow $ssh_port/tcp
  [[ $open_80 == "y" || $open_80 == "Y" ]] && ufw allow 80/tcp
  [[ $open_443 == "y" || $open_443 == "Y" ]] && ufw allow 443/tcp
else
  echo "[WARN] 未安裝 ufw，跳過防火牆設定"
fi

# === 4. 重新啟動 SSH ===
echo "[INFO] 重新啟動 SSH 服務..."
systemctl restart ssh

echo "[DONE] SSH 設定已完成，請使用 port $ssh_port 登入"
