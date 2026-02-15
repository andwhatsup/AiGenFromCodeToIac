output "endpoint" {
  value       = module.compute.alb_dns
  description = "DNS name to access the hello world service"
}