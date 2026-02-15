variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name prefix for resources."
  type        = string
  default     = "phantosio-minecraft"
}

variable "instance_type" {
  description = "EC2 instance type for the Minecraft host."
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Optional EC2 key pair name for SSH access. If null, no key is attached."
  type        = string
  default     = null
}

variable "minecraft_port" {
  description = "Minecraft server port."
  type        = number
  default     = 25565
}

variable "rcon_web_port" {
  description = "RCON web admin port (itzg/rcon)."
  type        = number
  default     = 4326
}

variable "rcon_port" {
  description = "Minecraft RCON port."
  type        = number
  default     = 25575
}

variable "minecraft_memory" {
  description = "Memory setting passed to itzg/minecraft-server (e.g., 2G)."
  type        = string
  default     = "2G"
}

variable "minecraft_version" {
  description = "Minecraft version passed to itzg/minecraft-server."
  type        = string
  default     = "1.19.2"
}

variable "minecraft_type" {
  description = "Server type passed to itzg/minecraft-server (e.g., PAPER)."
  type        = string
  default     = "PAPER"
}

variable "rcon_password" {
  description = "RCON password for the Minecraft server and RCON web admin."
  type        = string
  sensitive   = true
  default     = "Test"
}

variable "rcon_web_username" {
  description = "Username for RCON web admin."
  type        = string
  default     = "admin"
}

variable "rcon_web_password" {
  description = "Password for RCON web admin."
  type        = string
  sensitive   = true
  default     = "admin"
}
