# Define an AWS CloudWatch event rule for triggering a Lambda function every minute
resource "aws_cloudwatch_event_rule" "lambda_cron" {
  name                = "lambda-minute-trigger"
  description         = "Triggers Lambda every minute"
  schedule_expression = "cron(* * * * ? *)" # Cron expression for triggering every minute
}

# Define an AWS CloudWatch event target for the Lambda function
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_cron.name # Use the name of the event rule as the target rule
  target_id = "LambdaFunctionTarget"
  arn       = aws_lambda_function.example.arn # Use the ARN of the Lambda function as the target ARN
}

# Define an AWS Lambda permission to allow execution from EventBridge
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name # Use the name of the Lambda function
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_cron.arn # Use the ARN of the event rule as the source ARN
}
