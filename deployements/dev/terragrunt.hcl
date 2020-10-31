dependency "CI_CD" {
  config_path = "${get_parent_terragrunt_dir()}/../../CI_CD"
}

locals {
  env = "dev" 
}

generate "shared_variables" {
  path = "shared_variables.tf"
  if_exists = "overwrite"
  contents = <<EOF

variable "resource_prefix" {}
variable "client" {}
variable "project_id" {}
variable "private_bucket_name" {}
variable "private_bucket_arn" {}
variable "tf_state_bucket_name" {}
variable "tf_state_bucket_arn" {}
variable "dag_s3_prefix" {}
variable "region" {}
variable "env" {}
variable "tags" {
  type = map(string)
}
EOF
}

inputs = {
  resource_prefix = "${dependency.CI_CD.outputs.client}-${dependency.CI_CD.outputs.project_id}-${local.env}"
  dag_s3_prefix =  "s3://${dependency.CI_CD.outputs.private_bucket_name}/${dependency.CI_CD.outputs.project_id}/deployment/${local.env}/${path_relative_to_include()}"
  source_data_s3_key_prefix = "data"
  client = "${dependency.CI_CD.outputs.client}"
  project_id = "${dependency.CI_CD.outputs.project_id}"
  private_bucket_name = "${dependency.CI_CD.outputs.private_bucket_name}"
  private_bucket_arn = "${dependency.CI_CD.outputs.private_bucket_arn}"
  tf_state_bucket_name = "${dependency.CI_CD.outputs.tf_state_bucket_name}"
  tf_state_bucket_arn = "${dependency.CI_CD.outputs.tf_state_bucket_arn}"
  ecr_repo_url = "${dependency.CI_CD.outputs.ecr_repo_url}"
  deployment_group_name = "${dependency.CI_CD.outputs.deployment_group_name}"
  region = "${dependency.CI_CD.outputs.region}"
  env = "${local.env}"
  tags = {
    terraform_path = path_relative_to_include()
    client = "${dependency.CI_CD.outputs.client}"
    project_id = "${dependency.CI_CD.outputs.project_id}"
    private_bucket = "${dependency.CI_CD.outputs.private_bucket_name}"
    tf_state_bucket = "${dependency.CI_CD.outputs.tf_state_bucket_name}"
    region = "${dependency.CI_CD.outputs.region}"
    environment = "${local.env}"
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = "${dependency.CI_CD.outputs.tf_state_bucket_name}"
    key = "${dependency.CI_CD.outputs.project_id}/deployment/${local.env}/${path_relative_to_include()}/tf-state/terraform.tfstate"
    region         = "us-west-2"
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "aws" {
  version = "~> 2.70.0"
  region  = "us-west-2"
}
EOF
}
