include {
  path = find_in_parent_folders()
}

dependency "shared_account_data" {
  config_path = "../../global"
}

locals {
  dev_roles_arns = dependency.shared_account_data.outputs.dev_roles_arns
  staging_roles_arns = dependency.shared_account_data.outputs.staging_roles_arns
  prod_roles_arns = dependency.shared_account_data.outputs.prod_roles_arns
}

inputs = {
  aws_groups = [
    {
      name = "cross-account-full-access"
      assumable_roles = [
        dev_roles_arns["full_access"],
        staging_roles_arns["full_access"],
        prod_roles_arns["full_access"]
      ]
      group_users = [
        "Joe"
      ]
    },
    {
      name = "cross-account-read-access"
      assumable_roles = [
        dev_roles_arns["read_access"],
        staging_roles_arns["read_access"],
        prod_roles_arns["read_access"]
      ]
      group_users = [
        "Ann"
      ]
    },
  ]
  aws_users = [
    {
      name = "Joe"
      tags = {
        "position" = "lead-dev"
      }
      create_iam_user_login_profile = false
      create_iam_access_key         = false
    },
    {
      name = "Ann"
      tags = {
        "position" = "data-engineer"
      }
      create_iam_user_login_profile = false
      create_iam_access_key         = false
    }
  ]
}