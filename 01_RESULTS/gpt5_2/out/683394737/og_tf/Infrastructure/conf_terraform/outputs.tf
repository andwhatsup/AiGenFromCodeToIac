output "lb_url" {
  description = "URL of load balancer"
  value       = aws_elb.demo-elb.dns_name
}
