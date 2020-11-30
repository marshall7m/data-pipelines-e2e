locals {
  org_vars = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  aws_account_id = local.org_vars.locals.aws_account_ids.shared_services

  tf_state_bucket_name = "private-demo-org"
}