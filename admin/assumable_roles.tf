module "iam_assumable_role_customers" {
  source = "github.com/terraform-aws-modules/terraform-aws-iam/modules/iam-assumable-role"

  role_name = "customer-read-access-role"

  trusted_role_arns = [module.dag_customers.this_iam_user_arn]
  trusted_role_actions = [
      "sts:AssumeRole"
  ]
  
  create_role = true

  custom_role_policy_arns = [
    aws_iam_policy.customers.arn
  ]

  number_of_custom_role_policy_arns = 1
  
  role_requires_mfa = false

  tags = {
    Role = "customer-access"
  }
}

module "iam_assumable_role_lead_developers" {
  source = "github.com/terraform-aws-modules/terraform-aws-iam/modules/iam-assumable-role"

  role_name = "lead-developers-deployment-role"

  trusted_role_arns = [module.dag_customers.this_iam_user_arn]
  trusted_role_actions = [
      "sts:AssumeRole"
  ]
  
  create_role = true

  custom_role_policy_arns = [
    aws_iam_policy.lead_developers.arn
  ]

  number_of_custom_role_policy_arns = 1
  
  role_requires_mfa = false

  tags = {
    Role = "lead-developer-access"
  }
}

module "iam_assumable_role_developers" {
  source = "github.com/terraform-aws-modules/terraform-aws-iam/modules/iam-assumable-role"

  role_name = "developers-deployment-role"

  trusted_role_arns = [module.dag_customers.this_iam_user_arn]
  trusted_role_actions = [
      "sts:AssumeRole"
  ]
  
  

  custom_role_policy_arns = [
    aws_iam_policy.developers.arn
  ]

  create_role = true
  number_of_custom_role_policy_arns = 1
  role_requires_mfa = false

  tags = {
    Role = "developer-access"
  }
}

module "iam_assumable_role_airflow_instances" {
  source = "github.com/terraform-aws-modules/terraform-aws-iam/modules/iam-assumable-role"
  role_name = "airflow-ec2-role"
  trusted_role_services = ["ec2.amazonaws.com"]
  create_instance_profile = true

  create_role = true
  number_of_custom_role_policy_arns = 2
  role_requires_mfa = false

  custom_role_policy_arns = [
    aws_iam_policy.ssm_managed_core.arn,
    aws_iam_policy.instance_ssm_access.arn,
  ]
}

module "iam_assumable_role_codebuild" {
  # for_each = toset(local.aws_provider_aliases)
  source = "github.com/terraform-aws-modules/terraform-aws-iam/modules/iam-assumable-role"
  role_name = "codebuild-role"
  trusted_role_services = ["codebuild.amazonaws.com"]

  custom_role_policy_arns = [
    aws_iam_policy.codebuild_terraform.arn
  ]

  create_role = true
  number_of_custom_role_policy_arns = 1
  role_requires_mfa = false
  # providers = {
  #   aws = each.value
  # }
}