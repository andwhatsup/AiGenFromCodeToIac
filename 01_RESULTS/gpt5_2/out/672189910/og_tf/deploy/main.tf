provider "aws" {
  region = "us-west-2"
}


resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_s3_fullaccess" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}



resource "aws_s3_bucket" "bucket" {
  bucket        = "llm-documentation-bucket"
  force_destroy = true

  tags = {
    Name = "LLM Documentation"
  }
}


resource "aws_instance" "datadownloader" {
  ami           = "ami-00970f57473724c10"
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y wget
              yum install -y aws-cli
              wget -r -A.html -P langchain-docs https://api.python.langchain.com/en/latest/
              aws s3 sync langchain-docs s3://llm-documentation-bucket/langchain-docs
              shutdown -h now
              EOF

  tags = {
    Name = "datadownloader-instance"
  }
}