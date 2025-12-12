#!/bin/bash

clear

sudo apt update && sudo apt upgrade -y

sudo apt install build-essential libnss3-dev libssl-dev wget libreadline-dev libffi-dev pkg-config zlib1g-dev libncurses5-dev libgdbm-dev wget tar -y

cd /opt
sudo wget https://www.python.org/ftp/python/3.14.2/Python-3.14.2.tgz

sudo tar -xf Python-3.14.2.tgz
cd Python-3.14.2/
sudo ./configure --enable-optimizations

sudo make altinstall

sudo apt install python3-pip python3-venv -y

clear

echo "Done"