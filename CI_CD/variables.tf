variable "resource_prefix" {}

variable "github_repo_url" {}

variable "client" {}

variable "project_id" {}

variable "region" {}

variable "private_bucket_name" {}

variable "tf_state_bucket_name" {}

variable "aws_caller_user_id" {}

variable "tags" {
  type = map(string)
}