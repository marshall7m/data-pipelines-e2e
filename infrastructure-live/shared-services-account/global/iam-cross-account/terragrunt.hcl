include {
  path = find_in_parent_folders()
}

terraform {
    source = "github.com/marshall7m/tf_modules/terraform-aws-account-iam-roles"
}

locals {
  org_vars = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  org = local.org_vars.locals.org
  entrypoint_id = local.org_vars.locals.account_ids.entrypoint
  shared_services_id = local.org_vars.locals.account_ids.shared_services
  dev_id = local.org_vars.locals.account_ids.dev
  
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_id = local.account_vars.locals.account_id

  policies = yamldecode(templatefile("policies.yml", {
    account_id = local.account_id
    shared_services_id = local.shared_services_id
    entrypoint_id = local.entrypoint_id
  }))

}

inputs = {  
  admin_role_cross_account_arns = ["arn:aws:iam::${local.entrypoint_id}:root"]
  custom_admin_role_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]

  dev_role_cross_account_arns = ["arn:aws:iam::${local.entrypoint_id}:root"]
  custom_dev_role_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]

  read_role_cross_account_arns = ["arn:aws:iam::${local.entrypoint_id}:root"]
  custom_read_role_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  
  tf_plan_role_cross_account_arns = ["arn:aws:codebuild:us-west-2:${local.shared_services_id}:project/${local.org}-tf-infrastructure-us-west-2"]
  tf_plan_statements = local.policies["tf_plan_statements"]
  
  tf_apply_role_cross_account_arns = ["arn:aws:codebuild:us-west-2:${local.shared_services_id}:project/${local.org}-tf-infrastructure-us-west-2"]
  tf_apply_statements = local.policies["tf_apply_statements"]

}