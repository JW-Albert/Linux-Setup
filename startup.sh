#!/bin/bash

./albert.sh
./sshd.sh
./ufw.sh
./timedatectl-Debian12.sh

cd Tell_Me_after_Boot
./boot.sh

cd ~
rm -Rf Linux-Setup
