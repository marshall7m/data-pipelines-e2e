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

variable "env" {
  default = "dev"
}

variable "region" {
  default = "us-west-2"
}

data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "private-sparkify"
    key    = "${var.project_id}/networking/${var.env}/tf-state/terraform.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "CI_CD" {
  backend = "s3"
  config = {
    bucket = "private-sparkify"
    key    = "${var.project_id}/CI_CD/tf-state/terraform.tfstate"
    region = "us-west-2"
  }
}
