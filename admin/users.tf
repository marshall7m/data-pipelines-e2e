
module "dag_customers" {
  source = "github.com/terraform-aws-modules/terraform-aws-iam/modules/iam-user"

  name = "test-user"

  tags = {
    "access-customer" = "test-user"
  }

  create_iam_user_login_profile = false
  create_iam_access_key         = false
}