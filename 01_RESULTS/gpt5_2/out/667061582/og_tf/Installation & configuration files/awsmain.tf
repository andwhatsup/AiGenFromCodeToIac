provider "aws" {
  region     = "ap-south-1"
  access_key = "<access_key>"
  secret_key = "<secret_key>"

}

resource "aws_instance" "web" {
  for_each = var.instance_tags

  ami           = "ami-0376ec8eacdf70aae"
  instance_type = "t2.micro"
  key_name      = "my-key-pair"

  tags = each.value

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd mod_ssl

    # Generate a self-signed SSL certificate
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/pki/tls/private/webserver.key \
      -out /etc/pki/tls/certs/webserver.crt \
      -subj "/C=US/ST=State/L=City/O=Organization/CN=webserver.example.com"

    # Configure Apache to use the SSL certificate
    sudo sed -i 's/^Listen 80$/Listen 0.0.0.0:80/' /etc/httpd/conf/httpd.conf
    sudo sed -i 's/^<VirtualHost _default_:443>$/<VirtualHost _default_:443>\n  SSLEngine on\n  SSLCertificateFile \/etc\/pki\/tls\/certs\/webserver.crt\n  SSLCertificateKeyFile \/etc\/pki\/tls\/private\/webserver.key\n/' /etc/httpd/conf.d/ssl.conf

    # Configure firewall rules
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --permanent --add-service=https
    sudo firewall-cmd --reload

    sudo systemctl start httpd
    sudo systemctl enable httpd
  EOF
}

variable "instance_tags" {
  type = map(map(string))
  default = {
    web-1 = {
      Name        = "jenkins_Master",
      Environment = "dev",
    }
    web-2 = {
      Name        = "app_build_server",
      Environment = "build",
    }
    web-3 = {
      Name        = "kube_master",
      Environment = "deploy",
    }
    web-4 = {
      Name        = "kube_worknode1",
      Environment = "deploy",
    }
    web-5 = {
      Name        = "monitoring_server",
      Environment = "test&monitor",
    }
  }
}
