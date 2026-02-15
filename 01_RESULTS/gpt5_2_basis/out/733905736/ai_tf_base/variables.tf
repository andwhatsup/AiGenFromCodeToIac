variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name prefix for resources."
  type        = string
  default     = "sonarqube"
}

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default = {
    Project = "iac-docker-adm-sonarqube"
    Managed = "terraform"
  }
}

variable "sonarqube_image" {
  description = "Container image for SonarQube."
  type        = string
  default     = "sonarqube:10.4.1-community"
}

variable "sonarqube_container_port" {
  description = "SonarQube listens on this port in the container."
  type        = number
  default     = 9000
}

variable "desired_count" {
  description = "Number of ECS tasks to run."
  type        = number
  default     = 1
}
