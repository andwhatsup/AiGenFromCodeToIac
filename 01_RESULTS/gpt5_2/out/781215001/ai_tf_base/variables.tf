variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "infrafy"
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "infrafy"
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "kiwi"
}

variable "db_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}

variable "db_allocated_storage" {
  description = "RDS allocated storage (GiB)"
  type        = number
  default     = 20
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_publicly_accessible" {
  description = "Whether the DB should be publicly accessible (dev only)"
  type        = bool
  default     = true
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to Postgres (dev only)."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
