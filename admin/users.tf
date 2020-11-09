
module "data_engineer_users" {
  for_each = toset(var.data_engineer_usernames)
  source = "github.com/terraform-aws-modules/terraform-aws-iam/modules/iam-user"

  name = each.value

  tags = {
    "access-team" = "test-team"
  }

  create_iam_user_login_profile = false
  create_iam_access_key         = false
}