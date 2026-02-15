resource "tls_private_key" "example" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.example.public_key_openssh
}

resource "local_file" "myKey" {
  content  = tls_private_key.example.private_key_pem
  filename = "${aws_key_pair.generated_key.key_name}.pem"
}

resource "aws_security_group" "instance" {
  name        = "instance"
  description = "Allow inbound traffic"

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//create a new instance with ssk key generated
resource "aws_instance" "example-instance" {
  ami           = "ami-00ac45f3035ff009e"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name

  tags = {
    Name = "example-instance"
  }

  //create a new security group
  vpc_security_group_ids = [aws_security_group.instance.id]
}


resource "null_resource" "name" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.example.private_key_pem
    host        = aws_instance.example-instance.public_ip
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "mv /tmp/script.sh ./script.sh",
      "chmod +x script.sh",
      "sudo ./script.sh"
    ]
  }

  depends_on = [aws_instance.example-instance]
}

