# Create Lambda function
resource "aws_lambda_function" "humid_temp_sensors" {
  function_name = "Humidity_and_temperature_SonOff_sensors"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.home_automation.repository_url}:latest"
  role          = aws_iam_role.home_automation_lambda_role.arn
  timeout       = 10
  architectures = ["x86_64"]

  environment {
    variables = {
      INFLUXDB_URL    = var.influxdb_url
      INFLUXDB_TOKEN  = var.influxdb_token
      INFLUXDB_ORG    = var.influxdb_org
      INFLUXDB_BUCKET = var.influxdb_bucket
      TUYA_APIKEY     = var.tuya_apikey
      TUYA_APISECRET  = var.tuya_apisecret
      TUYA_APISREGION = var.tuya_apisregion
    }
  }
}

resource "aws_cloudwatch_event_rule" "every_30_minutes" {
  name                = "every-30-minutes"
  description         = "Triggers lambda function every 30 minutes"
  schedule_expression = "rate(30 minutes)"
}

resource "aws_lambda_permission" "allow_clw_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.humid_temp_sensors.function_name
  principal     = "events.amazonaws.com"

  source_arn = aws_cloudwatch_event_rule.every_30_minutes.arn
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.every_30_minutes.name
  arn  = aws_lambda_function.humid_temp_sensors.arn
}