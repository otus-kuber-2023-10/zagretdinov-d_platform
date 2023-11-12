#!/bin/bash
sudo apt install -y curl wget apt-transport-https
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
sudo groupadd docker
sudo usermod -aG docker $USER && newgrp docker
#minikube start --driver=docker