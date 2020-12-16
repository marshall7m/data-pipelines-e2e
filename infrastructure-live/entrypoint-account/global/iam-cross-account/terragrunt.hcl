include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/marshall7m/terraform-modules/terraform-aws-account-iam-roles"
}

locals {
  org_vars           = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  entrypoint_id      = local.org_vars.locals.account_ids.entrypoint
  shared_services_id = local.org_vars.locals.account_ids.shared_services

  account_vars         = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_id           = local.account_vars.locals.account_id
  tf_state_bucket_name = local.account_vars.locals.tf_state_bucket_name
}

inputs = {
  admin_role_cross_account_arns = ["arn:aws:iam::${local.entrypoint_id}:root"]
  custom_admin_role_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]

  dev_role_cross_account_arns   = ["arn:aws:iam::${local.entrypoint_id}:root"]
  custom_admin_role_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]

  read_role_cross_account_arns  = ["arn:aws:iam::${local.entrypoint_id}:root"]
  custom_admin_role_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]

  custom_tf_plan_role_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  tf_plan_allowed_actions = [
    "tag:Get*",
    "s3:List*",
    "s3:Get*",
    "iam:List*",
    "iam:Get*",
    "iam:Generate*"
  ]

  tf_apply_allowed_actions = [
    "tag:Get*",
    "s3:List*",
    "s3:Get*",
    "iam:List*",
    "iam:Get*",
    "iam:Generate*",
    "iam:Create*",
    "iam:Update*"
  ]

  limited_s3_read_role_cross_account_arns = [
    "arn:aws:iam::${local.dev_id}:root"
  ]

  limited_s3_read_statements = [
    {
      effect = "Allow"
      resources = [
        "arn:aws:s3:::${local.tf_state_bucket_name}/shared_data/terraform.tfstate"
      ]
      actions = ["s3:GetObject"]
    }
  ]

  common_allowed_actions = ["sts:AssumeRole"]
  common_allowed_resources = [
    "arn:aws:iam::${local.shared_services_id}:role/limited-s3-read-access",
    "arn:aws:iam::${local.entrypoint_id}:role/limited-s3-read-access"
  ]
}