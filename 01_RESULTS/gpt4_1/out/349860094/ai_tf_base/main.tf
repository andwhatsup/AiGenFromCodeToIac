resource "aws_dynamodb_table" "announcements" {
  name         = "${var.app_name}-announcements"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "URL"

  attribute {
    name = "URL"
    type = "S"
  }

  # Removed the unused attribute "TTL" from the attributes block

  ttl {
    attribute_name = "TTL"
    enabled        = true
  }

  tags = {
    Name = "${var.app_name}-announcements"
  }
}

resource "aws_sns_topic" "announcements" {
  name = "${var.app_name}-announcements"
  tags = {
    Name = "${var.app_name}-announcements"
  }
}

resource "aws_ssm_parameter" "telegram_auth_token" {
  name  = var.telegram_auth_token_param
  type  = "SecureString"
  value = "REPLACE_WITH_YOUR_TOKEN"
}
