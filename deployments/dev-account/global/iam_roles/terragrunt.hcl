include {
  path = find_in_parent_folders()
}

terraform {
    source = "github.com/marshall7m/tf_modules/terraform-aws-account-iam-roles"
}

locals {
  org_vars = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  entrypoint_id = local.org_vars.locals.aws_account_ids.entrypoint
  shared_services_id = local.org_vars.locals.aws_account_ids.shared_services
  
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tf_state_bucket_name = local.account_vars.locals.tf_state_bucket_name
}

inputs = {  
  admin_role_cross_account_arns = ["arn:aws:iam::${local.entrypoint_id}:root"]
  custom_admin_role_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]

  dev_role_cross_account_arns = ["arn:aws:iam::${local.entrypoint_id}:root"]
  custom_admin_role_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]

  read_role_cross_account_arns = ["arn:aws:iam::${local.entrypoint_id}:root"]
  custom_admin_role_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  
  custom_tf_plan_role_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  tf_plan_allowed_actions = [
    "tag:Get*",
    "s3:List*",
    "s3:Get*",
    "redshift:GetReservedNodeExchangeOfferings",
    "redshift:Describe*",
    "rds:List*",
    "rds:Download*",
    "rds:Describe*",
    "logs:TestMetricFilter",
    "logs:StopQuery",
    "logs:StartQuery",
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
    "glue:ListWorkflows",
    "glue:ListTriggers",
    "glue:ListMLTransforms",
    "glue:ListJobs",
    "glue:ListDevEndpoints",
    "glue:ListCrawlers",
    "glue:GetWorkflowRuns",
    "glue:GetWorkflowRunProperties",
    "glue:GetWorkflowRun",
    "glue:GetWorkflow",
    "glue:GetUserDefinedFunctions",
    "glue:GetUserDefinedFunction",
    "glue:GetTriggers",
    "glue:GetTrigger",
    "glue:GetTags",
    "glue:GetTables",
    "glue:GetTableVersions",
    "glue:GetTableVersion",
    "glue:GetTable",
    "glue:GetSecurityConfigurations",
    "glue:GetSecurityConfiguration",
    "glue:GetResourcePolicy",
    "glue:GetPlan",
    "glue:GetPartitions",
    "glue:GetPartition",
    "glue:GetMapping",
    "glue:GetMLTransforms",
    "glue:GetMLTransform",
    "glue:GetMLTaskRuns",
    "glue:GetMLTaskRun",
    "glue:GetJobs",
    "glue:GetJobRuns",
    "glue:GetJobRun",
    "glue:GetJobBookmark",
    "glue:GetJob",
    "glue:GetDevEndpoints",
    "glue:GetDevEndpoint",
    "glue:GetDataflowGraph",
    "glue:GetDatabases",
    "glue:GetDatabase",
    "glue:GetDataCatalogEncryptionSettings",
    "glue:GetCrawlers",
    "glue:GetCrawlerMetrics",
    "glue:GetCrawler",
    "glue:GetClassifiers",
    "glue:GetClassifier",
    "glue:GetCatalogImportStatus",
    "glue:BatchGetWorkflows",
    "glue:BatchGetTriggers",
    "glue:BatchGetPartition",
    "glue:BatchGetJobs",
    "glue:BatchGetDevEndpoints",
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
    "codebuild:BatchGet*",
    "athena:List*",
    "athena:Get*",
    "athena:Batch*"
  ]

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

  limited_s3_read_role_cross_account_arns = [
    "arn:aws:iam::${local.shared_services_id}:root"  
  ]

  limited_s3_read_statements = [
      {
          effect = "Allow"
          resources = [
            "arn:aws:s3:::${local.tf_state_bucket_name}/dev-account/global/iam_roles/terraform.tfstate"
          ]
          actions = ["s3:GetObject"]
      }
  ]

  common_allowed_actions = ["sts:AssumeRole"]
  common_allowed_resources = [
    "arn:aws:iam::${local.shared_services_id}:role/limited-s3-read-access",
    "arn:aws:iam::${local.entrypoint_id}:role/limited-s3-read-access"
  ]
}