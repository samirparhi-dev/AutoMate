#!/bin/bash

#install git
sudo apt update -y
sudo apt install -y git openjdk-11-jdk git unzip wget

#install Nano

sudo apt install -y nano

#install PODMAN

sudo apt update

sudo apt install -y software-properties-common

source /etc/os-release
sudo sh -c "echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"

wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/Debian_${VERSION_ID}/Release.key -O Release.key
sudo apt-key add - < Release.key
sudo apt update
sudo apt install -y podman
sleep 60
source ~/.bashrc
podman system init -y
podman system start -y
podman --version
podman run -d --name sonarqube -p 9000:9000 sonarqube
#Sourcing the final Bashrc
source ~/.bashrc
