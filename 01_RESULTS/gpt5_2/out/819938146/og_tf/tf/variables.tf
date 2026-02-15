variable "name" {
  type    = string
  default = "transit-transform"
}

variable "vault_license" {
  type      = string
  sensitive = true
}
