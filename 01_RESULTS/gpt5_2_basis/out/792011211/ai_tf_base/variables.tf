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

variable "api_key_secret_name" {
  description = "Name of the Secrets Manager secret that stores the OpenWeatherMap API key JSON (e.g., {\"API_KEY\":\"...\"})."
  type        = string
  default     = "/python-weather-app/api-key"
}

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default = {
    Project = "python-weather-app"
    Managed = "terraform"
  }
}
