variable "region" {
  description = "The AWS region to deploy the Lambda function to."
  type        = string
  default     = "ca-central-1"
}

variable "form_url" {
  description = "The URL of the form to submit."
  type        = string

}