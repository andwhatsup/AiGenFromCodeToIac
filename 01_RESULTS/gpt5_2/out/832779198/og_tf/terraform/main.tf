module "ob_s3" {
  source                  = "./modules/s3-bucket"
  aws_region              = var.aws_region
  s3_bucket_name          = var.s3_bucket_name
  s3_bucket_force_destroy = true
  prefix                  = var.prefix_ob
  suffix                  = var.suffix_dev
  iam_assume_role_service = "lambda.amazonaws.com"
}

module "ob_s3_notifications" {
  source  = "terraform-aws-modules/s3-bucket/aws//modules/notification"
  version = "4.1.2"

  bucket = module.ob_s3.s3_bucket_id

  lambda_notifications = {
    lambda_function = {
      function_arn  = module.ob_lambda.lambda_function_arn
      function_name = module.ob_lambda.lambda_function_name
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = "source/"
    }
  }
}

module "ob_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.7.0"

  function_name      = "${var.prefix_ob}-${var.lambda_function_name}-${var.suffix_dev}"
  description        = "My awesome Ontwikkelingsbedrywighede (ob) handler"
  handler            = "lambda_function.lambda_handler"
  runtime            = "python3.8"
  role_name          = "${var.prefix_ob}-${var.lambda_role_name}-${var.suffix_dev}"
  attach_policy_json = true
  policy_json = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:*",
          "s3:*",
        ],
        Resource = "*",
        Effect   = "Allow",
      },
    ],
  })

  create_current_version_allowed_triggers = false
  create_package                          = false
  local_existing_package                  = "../lambda.zip"

  environment_variables = {
    BUCKET = module.ob_s3.s3_bucket_id
  }

  allowed_triggers = {
    s3 = {
      service       = "s3"
      source_arn    = module.ob_s3.s3_bucket_arn
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = "source/"
    }
  }
}
