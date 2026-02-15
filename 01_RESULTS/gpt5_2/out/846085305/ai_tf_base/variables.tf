variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for resource naming."
  type        = string
  default     = "home-automation"
}

variable "lambda_image_tag" {
  description = "Container image tag to deploy for the Lambda function."
  type        = string
  default     = "latest"
}

variable "lambda_schedule_expression" {
  description = "EventBridge schedule expression to trigger the Lambda."
  type        = string
  default     = "rate(5 minutes)"
}

# App configuration passed to Lambda as environment variables
variable "influxdb_url" {
  description = "InfluxDB URL reachable from Lambda (e.g., https://example.com:8086)."
  type        = string
}

variable "influxdb_token" {
  description = "InfluxDB token."
  type        = string
  sensitive   = true
}

variable "influxdb_org" {
  description = "InfluxDB organization."
  type        = string
}

variable "influxdb_bucket" {
  description = "InfluxDB bucket."
  type        = string
}

variable "tuya_apikey" {
  description = "Tuya Cloud API key."
  type        = string
  sensitive   = true
}

variable "tuya_apisecret" {
  description = "Tuya Cloud API secret."
  type        = string
  sensitive   = true
}

variable "tuya_apisregion" {
  description = "Tuya Cloud API region (e.g., us, eu, cn)."
  type        = string
}
