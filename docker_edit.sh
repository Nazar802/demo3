#!/bin/bash 
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl lsb-release gnupg software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce -y
sudo systemctl start docker
sudo systemctl enable docker
sudo mkdir jenkins_home/
sudo docker pull jenkins/jenkins:lts
sudo docker run --rm --name jenkins -d -p 8282:8080 -v jenkins_home:/var/jenkins_home/ -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod 777 /var/jenkins_home/
sudo chmod 666 /var/run/docker.sock
sudo chmod +x /usr/local/bin/docker-compose
sudo apt update
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt install -y terraform
sudo apt update
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo chmod +x kubectl
sudo mkdir -p ~/.local/bin/kubectl
sudo mv ./kubectl ~/.local/bin/kubectl
sudo apt update
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt update
sudo apt install azure-cli
sudo apt update
sudo apt -y install dirmngr
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt -y install nodejs
sudo apt update
sudo apt install maven