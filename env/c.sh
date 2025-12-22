#!/bin/bash

set -e

clear

sudo apt update && sudo apt upgrade -y

sudo apt install gcc g++ -y

clear

echo "[Done] GCC and G++ are installed."
