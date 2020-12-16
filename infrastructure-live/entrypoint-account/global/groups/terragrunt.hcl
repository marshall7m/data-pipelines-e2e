dependency "users" {
  config_path = "../users"
}

include {
  path = find_in_parent_folders()
}


locals {
  account_ids = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  aws_dev_id  = local.account_ids.locals.account_ids.dev
}

terraform {
  source = "github.com/marshall7m/terraform-modules/terraform-aws-iam-entrypoint-account-groups"
}

inputs = {
  aws_groups = [
    {
      name = "dev-account-admin-access"
      assumable_roles = [
        "arn:aws:iam::${local.aws_dev_id}:role/cross-account-admin-access"
      ]
      group_users = [
        dependency.users.outputs.users_config["Joe"].this_iam_user_name
      ]
    },
    {
      name = "dev-account-read-access"
      assumable_roles = [
        "arn:aws:iam::${local.aws_dev_id}:role/cross-account-read-access"
      ]
      group_users = [
        dependency.users.outputs.users_config["Ann"].this_iam_user_name
      ]
    }
  ]
}