#! /bin/bash

chmod +x send_ip.sh
mv send_ip.sh /root/Tell_Me_after_Boot

sudo mv send-ip.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable send-ip.service
systemctl start send-ip.service