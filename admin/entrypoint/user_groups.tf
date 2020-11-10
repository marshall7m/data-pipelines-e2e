# module "customer_iam_group_policies" {
#     source = "github.com/terraform-aws-modules/terraform-aws-iam/modules/iam-group-with-policies"
    
#     name = module.customer_iam_group.group_name

#     create_group = false
#     attach_iam_self_management_policy = true
# }
module "full_access_developers" {
  for_each = toset(local.aws_provider_aliases)
  source = "github.com/terraform-aws-modules/terraform-aws-iam/modules/iam-group-with-assumable-roles-policy"

  name = "full_access_devs"

  assumable_roles = [
    module.admin_access_roles[each.value].this_iam_role_arn
  ]

  group_users = [
    module.data_engineer_users["test-user"].this_iam_user_name
  ]
}

