locals {
  resource_prefix = "${var.client}-${var.project_id}-${var.env}"
}

variable "project_id" {
  default = "usr-olap"
}

variable "private_bucket" {
  default = "private-sparkify"
}

variable "client" {
  default = "sparkify"
}

variable "env" {}

variable "region" {
  default = "us-west-2"
}