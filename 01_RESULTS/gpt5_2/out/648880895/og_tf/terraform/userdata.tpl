#!/bin/bash
sudo yum update -y &&
sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx 
echo "Hello Nginx Demo" > /var/www/html/index.html