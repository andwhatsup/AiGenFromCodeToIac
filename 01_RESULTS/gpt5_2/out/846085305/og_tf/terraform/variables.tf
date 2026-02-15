variable "influxdb_url" {
  description = "URL of the InfluxDB"
  type        = string
}

variable "influxdb_token" {
  description = "Token for InfluxDB"
  type        = string
  sensitive   = true
}

variable "influxdb_org" {
  description = "Organization name for InfluxDB"
  type        = string
}

variable "influxdb_bucket" {
  description = "Bucket name for InfluxDB"
  type        = string
}

variable "tuya_apikey" {
  description = "API Key for Tuya"
  type        = string
}

variable "tuya_apisecret" {
  description = "API Secret for Tuya"
  type        = string
  sensitive   = true
}

variable "tuya_apisregion" {
  description = "API Region for Tuya"
  type        = string
}