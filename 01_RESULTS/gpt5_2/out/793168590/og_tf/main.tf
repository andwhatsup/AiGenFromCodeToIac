provider "aws" {
  region = "eu-west-1"  # Specify the AWS region
}

resource "aws_iam_role" "sagemaker_execution_role" {
  name = "SageMakerExecutionRole"  # Name of the IAM role

  assume_role_policy = jsonencode({  # Define the IAM role's assume role policy
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"  # Allow assuming the role
        Effect    = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"  # Service that can assume the role
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_access" {
  role       = aws_iam_role.sagemaker_execution_role.name  # Attach the IAM role to the policy
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"  # ARN of the policy
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.sagemaker_execution_role.name  # Attach the IAM role to the policy
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"  # ARN of the policy
}

resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.sagemaker_execution_role.name  # Attach the IAM role to the policy
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"  # ARN of the policy
}

resource "aws_sagemaker_model_package_group" "example" {
  model_package_group_name = "hello-world-group"  # Name of the model package group
}

resource "aws_sagemaker_model" "example" {
  name = "hello-world-model"  # Name of the model

  execution_role_arn = aws_iam_role.sagemaker_execution_role.arn  # ARN of the execution role

  primary_container {
    image = "511771194412.dkr.ecr.eu-west-1.amazonaws.com/test_sagemaker:latest"  # Docker image for the model
  }
}

resource "aws_sagemaker_endpoint_configuration" "example" {
  name = "hello-world-endpoint-config"  # Name of the endpoint configuration

  production_variants {
    variant_name          = "AllTraffic"  # Name of the variant
    model_name            = aws_sagemaker_model.example.name  # Name of the model
    initial_instance_count = 1  # Number of initial instances
    instance_type         = "ml.t2.medium"  # Instance type
  }
}

resource "aws_sagemaker_endpoint" "example" {
  name                 = "hello-world-endpoint"  # Name of the endpoint
  endpoint_config_name = aws_sagemaker_endpoint_configuration.example.name  # Name of the endpoint configuration
}
