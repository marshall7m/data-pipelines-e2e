include {
  path = find_in_parent_folders()
}

terraform {
    source = "github.com/marshall7m/tf_modules/terraform-aws-account-iam-roles"
}

locals {
  org_vars = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  entrypoint_id = local.org_vars.locals.account_ids.entrypoint
  shared_services_id = local.org_vars.locals.account_ids.shared_services
  org = local.org_vars.locals.org
  
  infrastructure_artifact_bucket = "${local.org}-infrastructure-us-west-2"

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_name = local.account_vars.locals.account_name

  allowed_account_tf_state_buckets = ["arn:aws:s3:::private-${local.org}-${local.account_name}-us-west-2-tf-state/*"]
}

inputs = {  
  admin_role_cross_account_arns = ["arn:aws:iam::${local.entrypoint_id}:root"]
  custom_admin_role_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]

  dev_role_cross_account_arns = ["arn:aws:iam::${local.entrypoint_id}:root"]
  custom_admin_role_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]

  read_role_cross_account_arns = ["arn:aws:iam::${local.entrypoint_id}:root"]
  custom_admin_role_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  
  tf_plan_role_cross_account_arns = ["arn:aws:iam::${local.shared_services_id}:root"]
  tf_plan_allowed_actions = [
    "tag:Get*",
    "s3:List*",
    "s3:Get*",
    "rds:List*",
    "rds:Download*",
    "rds:Describe*",
    "logs:TestMetricFilter",
    "logs:StopQuery",
    "logs:StartQuery",
    "logs:CreateLogStream",
    "logs:ListTagsLogGroup",
    "logs:Get*",
    "logs:FilterLogEvents",
    "logs:Describe*",
    "kms:List*",
    "kms:Get*",
    "kms:Describe*",
    "kms:Decrypt",
    "iam:List*",
    "iam:Get*",
    "iam:Generate*",
    "ecs:List*",
    "ecs:Describe*",
    "ecr:List*",
    "ecr:Get*",
    "ecr:Describe*",
    "ecr:BatchGet*",
    "ecr:BatchCheck*",
    "ec2messages:Get*",
    "ec2:SearchTransitGatewayRoutes",
    "ec2:Get*",
    "ec2:Describe*",
    "codedeploy:List*",
    "codedeploy:Get*",
    "codedeploy:BatchGet*",
    "codebuild:List*",
    "codebuild:DescribeTestCases",
    "codebuild:DescribeCodeCoverages",
    "codebuild:BatchGet*"
  ]
  tf_plan_allowed_resources = ["*"]
  tf_plan_statements = [
    {
      sid = "AccountTerraformStateBucketsAccess"
      effect = "Allow"
      resources = local.allowed_account_tf_state_buckets
      actions = [
        "s3:GetObject"
      ]
    }
  ]

  tf_apply_role_cross_account_arns = ["arn:aws:iam::${local.shared_services_id}:root"]
  tf_apply_allowed_actions = [
    "vpc:*",
    "glue:*",
    "athena:*",
    "redshift:*",
    "rds:*",
    "logs:*",
    "ec2:*",
    "s3:*", 
    "ecr:*", 
    "iam:GetPolicy", 
    "iam:GetPolicyVersion",
    "iam:GetInstanceProfile", 
    "iam:ListEntitiesForPolicy",
    "iam:GetRole", 
    "iam:GetRolePolicy", 
    "iam:PassRole",
    "ssm:GetDocument",
    "ssm:DescribeAssociation",
    "ssm:GetParameters",
    "ssm:GetParameter",
    "ssm:PutParameter",
    "ssm:ListTagsForResource",
    "ssm:DescribeParameters",
    "kms:Decrypt"
  ]
  tf_apply_allowed_resources = ["*"]

  tf_apply_statements = [
    {
      sid = "AccountTerraformStateBucketsAccess"
      effect = "Allow"
      resources = local.allowed_account_tf_state_buckets
      actions = [
        "s3:PutObject",
        "s3:GetObject"
      ]
    }
  ]

  auto_deploy_role_cross_account_arns = ["arn:aws:iam::${local.shared_services_id}:root"]
  auto_deploy_statements = [
    {
      effect = "Allow"
      resources = ["*"]
      actions = [
        "codedeploy:CreateDeployment",
        "codedeploy:GetDeployment",
        "codedeploy:GetDeploymentConfig",
        "codedeploy:GetApplicationRevision",
        "codedeploy:RegisterApplicationRevision"
      ]
    },
    {
       effect = "Allow"
       resources = ["arn:aws:s3:::${local.infrastructure_artifact_bucket}/*"]
       actions = [
         "s3:GetObject*",
         "s3:PutObject",
         "s3:PutObjectAcl"    
       ]
     }
  ]
}