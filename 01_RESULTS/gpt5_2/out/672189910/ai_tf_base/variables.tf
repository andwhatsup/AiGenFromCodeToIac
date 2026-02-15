variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-west-2"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "llm-documentation"
}

variable "container_port" {
  description = "Port the Streamlit app listens on"
  type        = number
  default     = 8050
}
