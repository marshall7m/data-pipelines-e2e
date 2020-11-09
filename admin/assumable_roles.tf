module "admin_access_roles" {
  for_each = toset(local.aws_provider_aliases)
  source = "github.com/terraform-aws-modules/terraform-aws-iam/modules/iam-assumable-role"

  role_name = "${var.org}-admin-access"

  trusted_role_actions = [
      "sts:AssumeRole"
  ]
  custom_role_policy_arns = [aws_iam_policy.codebuild_terraform[each.value].arn]
  create_role = true
  attach_admin_policy = true
  role_requires_mfa = false

  tags = {
    Role = "admin-access"
  }
  
  providers = {
    aws = each.value
  }
}

# module "dev_read_access_roles" {
#   source = "github.com/terraform-aws-modules/terraform-aws-iam/modules/iam-assumable-role"

#   role_name = "${var.org}-read-access"

#   trusted_role_actions = [
#       "sts:AssumeRole"
#   ]
  
#   create_role = true
#   attach_readonly_policy = true  
#   role_requires_mfa = false

#   tags = {
#     Role = "${var.org}-read-access"
#   }
# }

# module "staging_full_access_role" {
#   source = "github.com/terraform-aws-modules/terraform-aws-iam/modules/iam-assumable-roles"

#   role_name = "${var.org}-full-access-developer"

#   trusted_role_actions = [
#       "sts:AssumeRole"
#   ]
  
#   create_role = true
#   attach_poweruser_policy = true
#   role_requires_mfa = false

#   tags = {
#     Role = "full-access-developer"
#   }
# }

# module "prod_full_access_role" {
#   source = "github.com/terraform-aws-modules/terraform-aws-iam/modules/iam-assumable-roles"

#   role_name = "${var.org}-full-access-developer"

#   trusted_role_actions = [
#       "sts:AssumeRole"
#   ]
  
#   create_role = true
#   attach_poweruser_policy = true
#   role_requires_mfa = false

#   tags = {
#     Role = "full-access-developer"
#   }
# }
