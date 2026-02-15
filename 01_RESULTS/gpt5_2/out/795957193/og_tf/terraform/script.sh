#!/bin/sh

sudo apt-get update
sudo apt-get install docker.io -y
sudo usermod -aG docker ubuntu
sudo systemctl start docker
sudo systemctl enable docker
sudo apt-get install git -y
git clone https://github.com:JustGritt/AWS-ExpressJS.git
sudo apt-get install npm -y
sudo apt-get install nodejs -y
cd AWS-ExpressJS
npm install
node server.js &