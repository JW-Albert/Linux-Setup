#!/bin/bash

clear

sudo apt update && sudo apt upgrade -y

sudo add-apt-repository ppa:deadsnakes/ppa

clear

sudo apt install python3.14 -y

sudo apt install python3-pip python3-venv -y

clear

echo "Done"
