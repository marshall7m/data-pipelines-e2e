locals {
  resource_prefix = "${var.client}-${var.project_id}"
}

variable "github_repo_url" {
  default = "https://github.com/marshall7m/sparkify_end_to_end.git"
}

variable "client" {
  default = "sparkify"
}

variable "project_id" {
  default = "usr-olap"
}

variable "private_bucket" {
  default = "private-sparkify"
}

