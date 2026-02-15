variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name/prefix for resources"
  type        = string
  default     = "phantosio-minecraft"
}

variable "instance_type" {
  description = "EC2 instance type for the Minecraft host"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Optional EC2 key pair name for SSH access"
  type        = string
  default     = null
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to the instance (set to your IP/32)."
  type        = string
  default     = "0.0.0.0/0"
}

variable "minecraft_port" {
  description = "Minecraft server port"
  type        = number
  default     = 25565
}

variable "rcon_web_port" {
  description = "RCON web admin port (itzg/rcon)"
  type        = number
  default     = 4326
}

variable "rcon_port" {
  description = "Minecraft RCON port"
  type        = number
  default     = 25575
}

variable "minecraft_memory" {
  description = "Memory setting passed to itzg/minecraft-server container"
  type        = string
  default     = "2G"
}

variable "minecraft_version" {
  description = "Minecraft version"
  type        = string
  default     = "1.19.2"
}

variable "minecraft_type" {
  description = "Server type (e.g., PAPER)"
  type        = string
  default     = "PAPER"
}

variable "motd" {
  description = "Message of the day"
  type        = string
  default     = "Vanilla Minecraft, Chill Vibes Only"
}

variable "rcon_password" {
  description = "RCON password (also used by rcon web admin)"
  type        = string
  sensitive   = true
  default     = "Test"
}

variable "rcon_web_username" {
  description = "RCON web admin username"
  type        = string
  default     = "admin"
}

variable "rcon_web_password" {
  description = "RCON web admin password"
  type        = string
  sensitive   = true
  default     = "admin"
}
