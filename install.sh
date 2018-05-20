#!/bin/bash

# Install Prerequisites

sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnome-terminal vim
sudo apt dist-upgrade -y


# Install Docker

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt install -y docker.io
sudo usermod -aG docker ${USER}
sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

# Install Visual Studio Code Editor

url https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install -y code
curl -L https://github.com/HASecuritySolutions/sec555_v2_build/raw/master/settings.json -o $HOME/.config/Code/User/settings.json

# Set up desktop environment

mkdir $HOME/555_files
curl -L https://github.com/HASecuritySolutions/sec555_v2_build/raw/master/sec555_coin.png -o $HOME/555_files/sec555_coin.png
curl -L https://github.com/HASecuritySolutions/sec555_v2_build/raw/master/purple_terminal.bmp -o $HOME/555_files/purple_terminal.bmp

xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/image-path --set $HOME/555_files/sec555_coin.png
xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/workspace0/image-path --set $HOME/555_files/sec555_coin.png
xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/workspace0/image-style --set 1
