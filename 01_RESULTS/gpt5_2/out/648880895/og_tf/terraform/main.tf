###########################
provider "aws" {
  region                      = "us-east-1"
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

# Below Code will generate a secure private key with encoding
resource "tls_private_key" "key" {
  algorithm = "ED25519"
}

# Create the Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "botos3_workshop"
  public_key = tls_private_key.key.public_key_openssh
}

# Save file
resource "local_file" "ssh_key" {

  filename        = "${aws_key_pair.key_pair.key_name}.pem"
  content         = tls_private_key.key.private_key_openssh
  file_permission = "0600"
}

## Policies
resource "aws_iam_role" "ec2_role" {
  name               = "ec2_role_workshop"
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

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}



data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.s3.id}",
      "arn:aws:s3:::${aws_s3_bucket.s3.id}/*"
    ]
    effect = "Allow"

  }
}

resource "aws_iam_role" "ec2_iam_role" {
  name = "ec2_iam_role"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance_profile"
  role = aws_iam_role.ec2_iam_role.name
}