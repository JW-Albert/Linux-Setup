#! /bin/bash

apt install curl -y

chmod +x send_ip.sh

mkdir /root/Tell_Me_after_Boot
mv send_ip.sh /root/Tell_Me_after_Boot/

sudo mv send-ip.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable send-ip.service
systemctl start send-ip.service
