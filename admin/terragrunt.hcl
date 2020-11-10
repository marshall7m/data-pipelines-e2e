locals {
  org = "demo-org"
  tf_state_bucket =  "private-${local.org}"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = local.tf_state_bucket
    key = "admin/${path_relative_to_include()}/tf-state/terraform.tfstate"
    region         = get_env("region", "us-west-2")
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "aws" {
  version = "~> 3.2.0"
  region  = var.region
  profile = var.aws_profile
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
EOF
}

generate "shared_variables" {
  path = "shared_variables.tf"
  if_exists = "overwrite"
  contents = <<EOF

variable "env" {
  default = null
}

variable "region" {
  default = null
}

variable "aws_profile" {
  default = null
}

variable "admin_role_name" {
  default = null
}

variable "admin_role_tags" {
  type = map(string)
  default = {}
}

variable "poweruser_role_name" {
  default = null
}

variable "poweruser_role_tags" {
  type = map(string)
  default = {}
}

variable "readonly_role_name" {
  default = null
}

variable "readonly_role_tags" {
  type = map(string)
  default = {}
}

EOF
}

inputs = {
  admin_role_name = "${local.org}-admin-access"
  admin_role_tags = {
    admin-access = true
  }

  poweruser_role_name = "${local.org}-full-access"
  poweruser_role_tags = {
    full-access = true
  }

  readonly_role_name = "${local.org}-read-access"
  readonly_role_tags = {
    read-access = true
  }

}


