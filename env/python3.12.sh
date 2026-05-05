#!/bin/bash
set -e
clear

# 安裝編譯依賴
echo ">>> 安裝依賴套件..."
sudo apt update
sudo apt install -y build-essential libssl-dev zlib1g-dev \
  libncurses5-dev libgdbm-dev libnss3-dev \
  libreadline-dev libffi-dev libsqlite3-dev \
  wget libbz2-dev liblzma-dev

# 下載原始碼
echo ">>> 下載 Python 3.12.13..."
wget https://www.python.org/ftp/python/3.12.13/Python-3.12.13.tar.xz

# 驗證 SHA-256
echo ">>> 驗證完整性..."
echo "c08bc65a81971c1dd5783182826503369466c7e67374d1646519adf05207b684  Python-3.12.13.tar.xz" | sha256sum -c -

# 解壓縮
tar -xf Python-3.12.13.tar.xz
cd Python-3.12.13

# 編譯安裝
echo ">>> 開始編譯（需要幾分鐘）..."
./configure --enable-optimizations
make -j$(nproc)
sudo make altinstall

clear
echo "Done"
python3.12 --version