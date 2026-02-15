variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name prefix for resources."
  type        = string
  default     = "atlas-template"
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "app"
}

variable "db_username" {
  description = "Master username for the RDS instance."
  type        = string
  default     = "appuser"
}

variable "db_password" {
  description = "Master password for the RDS instance. Must be at least 8 characters."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB."
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "MySQL engine version."
  type        = string
  default     = "8.0"
}

variable "db_publicly_accessible" {
  description = "Whether the DB should have a public endpoint. For minimal demo usage, default true."
  type        = bool
  default     = true
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the database (port 3306)."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
