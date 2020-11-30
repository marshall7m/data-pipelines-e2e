locals {
  organization_vars = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl", "null.hcl"), "null.hcl")
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl", "null.hcl"), "null.hcl")
  deployment_vars = read_terragrunt_config(find_in_parent_folders("deployment.hcl", "null.hcl"), "null.hcl")
  
  org = local.organization_vars.locals.org

  aws_region = try(local.region_vars.locals.aws_region, "us-west-2")

  common_tags = {
    terragrunt_path = "${path_relative_to_include()}"
    organization = "${local.org}"
  }  
  
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

inputs = {
  common_tags = local.common_tags
}
