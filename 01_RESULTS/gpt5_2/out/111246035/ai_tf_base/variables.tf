variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging."
  type        = string
  default     = "ssh-key-agent"
}

variable "container_image" {
  description = "Container image to run. Provide a full image URI (e.g., ECR repo URL:tag or public image)."
  type        = string
  default     = "quay.io/utilitywarehouse/ssh-key-agent:latest"
}

variable "ska_key_uri" {
  description = "URI location of the authmap file created by ssh-key-manager."
  type        = string
}

variable "ska_groups" {
  description = "List of groups that are allowed access."
  type        = list(string)
  default     = []
}

variable "ska_interval" {
  description = "Interval in seconds, how often the keys should be synced."
  type        = number
  default     = 60
}

variable "ska_akf_loc" {
  description = "Location of the authorized_keys file inside the container."
  type        = string
  default     = "/authorized_keys"
}
