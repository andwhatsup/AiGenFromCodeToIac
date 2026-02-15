output "instance_id" {
  description = "EC2 instance id running the Minecraft containers."
  value       = aws_instance.minecraft.id
}

output "public_ip" {
  description = "Public IP of the Minecraft host."
  value       = aws_instance.minecraft.public_ip
}

output "minecraft_address" {
  description = "Minecraft server address (host:port)."
  value       = "${aws_instance.minecraft.public_ip}:${var.minecraft_port}"
}

output "rcon_web_url" {
  description = "RCON web admin URL."
  value       = "http://${aws_instance.minecraft.public_ip}:${var.rcon_web_port}"
}
