output "instance_id" {
  value       = aws_instance.minecraft.id
  description = "EC2 instance id running the Minecraft docker-compose stack"
}

output "public_ip" {
  value       = aws_instance.minecraft.public_ip
  description = "Public IP of the Minecraft host"
}

output "minecraft_address" {
  value       = "${aws_instance.minecraft.public_ip}:${var.minecraft_port}"
  description = "Connect to Minecraft using this host:port"
}

output "rcon_web_url" {
  value       = "http://${aws_instance.minecraft.public_ip}:${var.rcon_web_port}"
  description = "RCON web admin URL"
}
