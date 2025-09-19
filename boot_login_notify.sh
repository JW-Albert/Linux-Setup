#!/bin/bash

# 安裝 curl
sudo apt update
sudo apt install -y curl

# 建立資料夾存放腳本
mkdir -p /root/Login_Notify

# 建立登入通知腳本
cat > /root/Login_Notify/login_notify.sh << 'EOF'
#!/bin/bash

SMTP_SERVER="smtp.gmail.com"
SMTP_PORT="587"
SENDER_EMAIL="jw.albert.tw@gmail.com"
SENDER_PASSWORD="cnbhqiltcgbqpvpo"
RECIPIENT_EMAIL="albert@mail.jw-albert.tw"

USER_NAME=$(whoami)
HOSTNAME=$(hostname)
DATE=$(date '+%Y-%m-%d %H:%M:%S')
IP_ADDR=$(echo $SSH_CONNECTION | awk '{print $1}')

SUBJECT="Login Alert: $USER_NAME on $HOSTNAME"
BODY="A user has logged in:

Date: $DATE
User: $USER_NAME
Host: $HOSTNAME
Source IP: $IP_ADDR
"

echo "Subject: $SUBJECT

$BODY" | curl -s \
    --url "smtp://$SMTP_SERVER:$SMTP_PORT" \
    --mail-from "$SENDER_EMAIL" \
    --mail-rcpt "$RECIPIENT_EMAIL" \
    --ssl-reqd \
    --user "$SENDER_EMAIL:$SENDER_PASSWORD" \
    --upload-file - \
    --mail-rcpt-allowfails \
    --fail-with-body
EOF

chmod +x /root/Login_Notify/login_notify.sh

# 建立 systemd service
cat > /etc/systemd/system/login-notify.service << 'EOF'
[Unit]
Description=Setup login notification script
After=network.target

[Service]
Type=oneshot
ExecStart=/root/Login_Notify/setup_login_notify.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

# 建立 setup_login_notify.sh
cat > /root/Login_Notify/setup_login_notify.sh << 'EOF'
#!/bin/bash
set -e

SCRIPT_PATH="/root/Login_Notify/login_notify.sh"
PAM_FILE="/etc/pam.d/sshd"

# 確保 PAM 裡有這行，沒有才加
if ! grep -q "$SCRIPT_PATH" "$PAM_FILE"; then
    echo "session optional pam_exec.so seteuid $SCRIPT_PATH" >> "$PAM_FILE"
    echo "[INFO] PAM sshd 已加上 login_notify.sh"
else
    echo "[INFO] PAM sshd 已經存在 login_notify.sh 設定"
fi
EOF

chmod +x /root/Login_Notify/setup_login_notify.sh

# 啟用並啟動服務
sudo systemctl daemon-reload
sudo systemctl enable login-notify.service
sudo systemctl start login-notify.service

