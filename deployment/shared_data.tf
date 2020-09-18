locals {
  project_id      = var.project_id
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

variable "env" {
  default = "dev"
}

data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket  = "private-sparkify"
    key  = "${local.project_id}/networking/${var.env}/tf-state/terraform.tfstate"
    region = "us-west-2"
  }
}
