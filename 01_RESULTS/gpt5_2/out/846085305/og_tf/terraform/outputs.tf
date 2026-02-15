# Output the repository URI
output "ecr_repository_uri" {
  value = "${aws_ecr_repository.home_automation.repository_url}:latest"
}
