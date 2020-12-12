include {
  path = find_in_parent_folders()
}

terraform {
  source = ""github.com/marshall7m/tf_modules/terraform-aws-entrypoint-account-users"
}

inputs = {
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