module "user_assumable_roles" {
  source = "github.com/terraform-aws-modules/terraform-aws-iam/modules/iam-assumable-roles"

  create_admin_role = true
  admin_role_name = var.admin_role_name
  admin_role_tags = var.admin_role_tags

  create_poweruser_role = true
  poweruser_role_name = var.poweruser_role_name
  poweruser_role_policy_arns = [

  ]
  poweruser_role_tags = var.poweruser_role_tags

  create_readonly_role = true
  readonly_role_name = var.readonly_role_name
  readonly_role_policy_arns = [
      
  ]
  readonly_role_tags = var.readonly_role_tags

}

