variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for resource naming/tagging."
  type        = string
  default     = "aws-rekognition"
}

variable "state_machine_definition_path" {
  description = "Path to the Step Functions state machine definition JSON."
  type        = string
  default     = "../state_machine/Rekognition.json"
}
