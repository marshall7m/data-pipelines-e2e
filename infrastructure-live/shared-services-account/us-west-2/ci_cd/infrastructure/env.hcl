locals {
  org_vars    = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  account_id         = local.org_vars.locals.account_ids.shared_services
  github_repo        = "marshall7m/sparkify_end_to_end"
  region             = local.region_vars.locals.region
  code_star_conn_arn = "arn:aws:codestar-connections:${local.region}:${local.account_id}:connection/<enter>"
}