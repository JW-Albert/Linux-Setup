#! /bin/bash

sudo apt install curl -y

sudo chmod +x send_ip.sh

mkdir /root/Tell_Me_after_Boot
mv send_ip.sh /root/Tell_Me_after_Boot/

sudo mv send-ip.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable send-ip.service
sudo systemctl start send-ip.service
