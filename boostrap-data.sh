#!/bin/bash

#install git
sudo apt update -y
sudo apt install -y git openjdk-11-jdk git unzip wget

#install Nano

sudo apt install -y nano

# Install Code QL

CODEQL_VERSION=$(curl -s https://api.github.com/repos/github/codeql-cli-binaries/releases/latest | grep tag_name | cut -d '"' -f 4)

wget "https://github.com/github/codeql-cli-binaries/releases/download/${CODEQL_VERSION}/codeql-linux64.zip"

sudo mkdir -p /opt/codeql

sudo unzip codeql-linux64.zip -d /opt/codeql
rm codeql-linux64.zip
echo 'export PATH=$PATH:/opt/codeql/codeql' >> ~/.bashrc
source ~/.bashrc
codeql --version

#install PODMAN

sudo apt update

sudo apt install -y software-properties-common

source /etc/os-release
sudo sh -c "echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"

wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/Debian_${VERSION_ID}/Release.key -O Release.key
sudo apt-key add - < Release.key
sudo apt update
sudo apt install -y podman
podman --version


#install go

curl -L https://golang.org/dl/go1.17.1.linux-amd64.tar.gz -o go1.17.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.17.1.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
source ~/.bashrc
sudo nano /etc/profile
export PATH=$PATH:/usr/local/go/bin
source /etc/profile

#Install Shasum
sudo apt update -y
sudo apt install -y coreutils

#install Open SSl
sudo apt update -y
sudo apt install -y openssl

#install trivy
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

#install kubectl
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y
sudo apt-get install -y kubectl


#install kubeaudit

sudo apt update

# Define the latest KubeAudit version
KUBEAUDIT_VERSION="0.18.0"
wget "https://github.com/Shopify/kubeaudit/releases/download/${KUBEAUDIT_VERSION}/kubeaudit_${KUBEAUDIT_VERSION}_linux_amd64.deb"
sudo dpkg -i "kubeaudit_${KUBEAUDIT_VERSION}_linux_amd64.deb"
rm "kubeaudit_${KUBEAUDIT_VERSION}_linux_amd64.deb"

#user Creation for Github Runner

USERNAME="spx7-k8s-deploy"
useradd -m -s /bin/bash $USERNAME
chown -R chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"
chmod 700 "/home/$USERNAME"
passwd -l "$USERNAME"
su -u -H $USERNAME

#GitHub Runner installation and configuration

mkdir actions-runner && cd actions-runner

curl -o actions-runner-linux-x64-2.317.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-linux-x64-2.317.0.tar.gz


echo "9e883d210df8c6028aff475475a457d380353f9d01877d51cc01a17b2a91161d  actions-runner-linux-x64-2.317.0.tar.gz" | shasum -a 256 -c

tar xzf ./actions-runner-linux-x64-2.317.0.tar.gz

./config.sh --url https://github.com/samirparhi-dev/JuiceApp --token <<token here>>

./actions-runner/run.sh

rm -rf ~/*.tar.gz

#Sourcing the final Bashrc
source ~/.bashrc
