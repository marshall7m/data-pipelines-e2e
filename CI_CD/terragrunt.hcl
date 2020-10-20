locals {
    client = "sparkify"
    project_id = "usr-olap"
    tf_state_bucket = "private-sparkify"
    private_bucket = "private-sparkify"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = local.tf_state_bucket
    key = "${local.project_id}/CI_CD/tf-state/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "aws" {
  version = "~> 3.2.0"
  region  = "us-west-2"
}
EOF
}

inputs = {
  aws_caller_user_id = get_aws_account_id()
  github_repo_url = "https://github.com/marshall7m/sparkify_end_to_end.git"
  client = local.client
  project_id = local.project_id
  resource_prefix = "${local.client}-${local.project_id}"
  private_bucket_name = local.private_bucket
  tf_state_bucket_name = local.private_bucket
  region = "us-west-2"
  tags = {
    "terraform"     = "true"
    "terraform_path" = "${local.project_id}/CI_CD/"
    "client" = "${local.client}"
    "project_id" = "${local.project_id}"
  }
}