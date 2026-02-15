variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for resource naming/tagging."
  type        = string
  default     = "home-automation"
}

variable "lambda_image_tag" {
  description = "ECR image tag for the Lambda container image."
  type        = string
  default     = "latest"
}

# App configuration passed to Lambda as environment variables
variable "influxdb_url" {
  description = "InfluxDB URL reachable from Lambda (e.g., https://example.com:8086)."
  type        = string
  default     = ""
  sensitive   = true
}

variable "influxdb_token" {
  description = "InfluxDB token."
  type        = string
  default     = ""
  sensitive   = true
}

variable "influxdb_org" {
  description = "InfluxDB organization."
  type        = string
  default     = ""
}

variable "influxdb_bucket" {
  description = "InfluxDB bucket."
  type        = string
  default     = ""
}

variable "tuya_apikey" {
  description = "Tuya Cloud API key."
  type        = string
  default     = ""
  sensitive   = true
}

variable "tuya_apisecret" {
  description = "Tuya Cloud API secret."
  type        = string
  default     = ""
  sensitive   = true
}

variable "tuya_apisregion" {
  description = "Tuya Cloud API region (e.g., eu, us, cn)."
  type        = string
  default     = ""
}

variable "schedule_expression" {
  description = "EventBridge schedule expression to trigger the Lambda."
  type        = string
  default     = "rate(5 minutes)"
}
