variable "customer_list" {
    default = ["test-user"]
}

variable "customer_actions" {
    default = [
        "s3:Get*",
        "s3:List*"
    ]
}

variable "deployment_access_tags" {
    default = {
        "aws:PrincipalTag/deployment_name" = [
            "deployment_one"
        ]
    }
}

variable "customer_access_tags" {
    default = {
        "aws:PrincipalTag/access_customer" = ["aws:ResourceTag/access-customer"]
    }
}

variable "full_access_actions" {
    default = [
        "glue:*",
        "athena:*",
        "redshift:*",
        "rds:*",
        "logs:*",
        "kms:*"
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