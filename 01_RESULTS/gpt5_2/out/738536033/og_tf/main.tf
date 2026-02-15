provider "aws" {
  region = "eu-west-2"
}

resource "aws_iam_role" "role" {
  name = "dash-eb-role"

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

resource "aws_iam_instance_profile" "instance_profile" {
  name = "dash-instance-profile"
  role = aws_iam_role.role.name
}

resource "aws_elastic_beanstalk_application" "dash_app" {
  name        = "dash-app"
  description = "Simple Dash Plotly app"
}

resource "aws_elastic_beanstalk_environment" "dash_app_env" {
  name                = "dash-app-env"
  application         = aws_elastic_beanstalk_application.dash_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.0.7 running Python 3.11"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.instance_profile.name
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "3"
  }
}

