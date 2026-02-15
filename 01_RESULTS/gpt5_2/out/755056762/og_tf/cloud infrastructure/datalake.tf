resource "aws_s3_bucket" "faker-bucker" {
  bucket = "faker-data-test-bucket"

  tags = {
    Team                 = "Core Data Engineers"
    Managed_by_terraform = "True"
    Service              = "Airflow"
    Name                 = "faker bucket"
    Environment          = "Dev"
  }
}