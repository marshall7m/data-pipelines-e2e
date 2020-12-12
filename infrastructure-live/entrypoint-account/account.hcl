locals {
  org_vars = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  account_id = local.org_vars.locals.account_ids.entrypoint
  account_name = "entrypoint"
}