# Terraform - Web Server Infrastructure Provisioning

This Terraform configuration provisions a web server infrastructure on AWS. It creates EC2 instances using the provided AMI, installs and configures Apache with SSL/TLS encryption, and sets up firewall rules.

## Prerequisites
Before you proceed, ensure you have the following prerequisites in place:
- Terraform CLI installed on your machine
- AWS credentials (access key and secret key) with appropriate permissions

## Configuration
To configure the Terraform provider and define the web server resources, perform the following steps:

1. Open a new file named `main.tf` and add the following code:

```hcl
provider "aws" {
  region     = "ap-south-1"
  access_key = "<your-access-key>"
  secret_key = "<your-secret-key>"
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
```

2. Update the `region`, `access_key`, and `secret_key` values in the `provider` block with your AWS credentials.

3. Customize the `ami`, `instance_type`, `key_name`, and `user_data` section as per your requirements.

4. Save the file.

## Deployment
To deploy the web server infrastructure using Terraform, follow these steps:

1. Open a terminal or command prompt.

2. Navigate to the directory where the `main.tf` file is saved.

3. Run the following command to initialize the Terraform working directory:

```
terraform init
```

4. After the initialization is complete, run the following command to preview the changes that Terraform will apply:

```
terraform plan
```

5. Review the plan and verify that it matches your expectations.

6. Run the following command to apply the changes and provision the web server infrastructure:

```
terraform apply
```

7. Terraform will prompt for confirmation. Enter `yes` to proceed with the deployment.

8. Wait for Terraform to provision the infrastructure. Once the process completes, it will display the outputs, including the public IP addresses of the created instances.

9. To destroy the infrastructure after you are done:

```
terraform destroy
```
