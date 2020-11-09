# variable "deployment_access_tags" {
#     default = {
#         "aws:PrincipalTag/deployment_name" = [
#             "aws:ResourceTag/deployment_name"
#         ]
#     }
# }

# variable "environment_access_tags" {
#     default = {
#         "aws:PrincipalTag/environment" = "aws:ResourceTag/environment"
#     }
# }

variable "data_engineer_usernames" {
    default = [
        "test-user"
    ]
}

variable "org" {
    default = "demo-org"
}

variable "full_access_actions" {
    default = [
        "vpc:*",
        "glue:*",
        "athena:*",
        "redshift:*",
        "rds:*",
        "logs:*",
        "kms:*",
        "codebuild:*",
        "ec2:*",
        "ecr:*",
        "codedeploy:*",
        "ssm:GetDocument",
        "ssm:DescribeAssociation",
        "ssm:GetParameters",
        "ssm:GetParameter",
        "ssm:PutParameter",
        "ssm:ListTagsForResource",
        "ssm:DescribeParameters"
    ]
}

variable "code_build_actions" {
    default = [
        "vpc:*",
        "glue:*",
        "athena:*",
        "redshift:*",
        "rds:*",
        "logs:*",
        "kms:*",
        "ec2:*",
        "ecr:*",
        "s3:*",
        "codebuild:*",
        "codedeploy:*",
        "ecr:*",
        "ssm:GetParameters",
        "ssm:GetParameter",
        "ssm:PutParameter",
        "ssm:ListTagsForResource",
        "ssm:GetDocument",
        "ssm:DescribeAssociation",
        "iam:PassRole",
        "iam:GetInstanceProfile"

    ]
}

variable "read_access_actions" {
    default = [
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
}

variable "airflow_instance_actions" {
    default = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "s3:GetObject",
        "s3:PutObject"
    ]
}