variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for resource naming."
  type        = string
  default     = "python-weather-app"
}

variable "tags" {
  description = "Tags applied to supported resources."
  type        = map(string)
  default = {
    Project = "python-weather-app"
    Managed = "terraform"
  }
}

variable "openweather_api_key_secret_name" {
  description = "Name of the Secrets Manager secret that contains the OpenWeather API key JSON (e.g., {\"API_KEY\":\"...\"})."
  type        = string
  default     = "/python-weather-app/api-key"
}

variable "openweather_api_key" {
  description = "OpenWeather API key value stored in Secrets Manager. Use a real value in production."
  type        = string
  default     = "CHANGEME"
  sensitive   = true
}

variable "container_port" {
  description = "Container port exposed by the application."
  type        = number
  default     = 5000
}

variable "desired_count" {
  description = "Number of ECS tasks to run."
  type        = number
  default     = 1
}
