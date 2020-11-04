module "customer_iam_group" {
  source = "github.com/terraform-aws-modules/terraform-aws-iam/modules/iam-group-with-assumable-roles-policy"

  name = "production-customers"

  assumable_roles = [module.iam_assumable_role_customers.this_iam_role_arn]

  group_users = [module.dag_customers.this_iam_user_name]
}

module "customer_iam_group_policies" {
    source = "github.com/terraform-aws-modules/terraform-aws-iam/modules/iam-group-with-policies"
    
    name = module.customer_iam_group.group_name

    create_group = false
    attach_iam_self_management_policy = true
}