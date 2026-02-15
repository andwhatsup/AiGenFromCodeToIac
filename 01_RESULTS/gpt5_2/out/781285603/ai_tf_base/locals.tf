locals {
  role_name   = var.use_suffixes ? "${var.name}-role" : var.name
  policy_name = var.use_suffixes ? "${var.name}-policy" : var.name
  group_name  = var.use_suffixes ? "${var.name}-group" : var.name
  user_name   = var.use_suffixes ? "${var.name}-user" : var.name
}
