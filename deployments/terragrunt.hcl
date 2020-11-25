locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl", "null.hcl"), "null.hcl")
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl", "null.hcl"), "null.hcl")
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl", "null.hcl"), "null.hcl")
  deployment_vars = read_terragrunt_config(find_in_parent_folders("deployment.hcl", "null.hcl"), "null.hcl")
  
  aws_account_name = local.account_vars.locals.aws_account_name
  aws_account_id   = local.account_vars.locals.aws_account_id
  aws_codebuild_arn = local.account_vars.locals.aws_codebuild_arn
  aws_region   = "us-west-2"
  
  org = "demo-org"
}

generate "global_variables" {
  path      = "global_variables.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
variable "common_tags" {
  default = {
    terragrunt_path = "${path_relative_to_include()}"
    organization = "${local.org}"
  }
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"  
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "private-${local.org}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals
)
