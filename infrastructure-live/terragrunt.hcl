locals {
  org_vars = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl", "null.hcl"), {locals = {region = "us-west-2"}})
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl", "null.hcl"), "null.hcl")
  deployment_vars = read_terragrunt_config(find_in_parent_folders("deployment.hcl", "null.hcl"), "null.hcl")
  
  org = local.org_vars.locals.org
  common_tags = local.org_vars.locals.common_tags
  account_name = try(local.account_vars.locals.account_name, null)
  region = local.region_vars.locals.region
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "private-${local.org}-${local.account_name}-${local.region}-tf-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = {
  common_tags = local.common_tags
}
