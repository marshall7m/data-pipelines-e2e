resource "aws_codebuild_webhook" "tf_pull_request" {
  project_name = aws_codebuild_project.tf_plan.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH,PULL_REQUEST_CREATED,PULL_REQUEST_UPDATED"
      # pattern = "PULL_REQUEST_CREATED,PULL_REQUEST_UPDATED"

    }

    filter {
      type    = "FILE_PATH"
      pattern = "^${var.deployment_directory}.*[.](tf|tfvars)$"
    }
  }
}

resource "aws_codebuild_webhook" "tf_merge" {
  project_name = aws_codebuild_project.tf_apply.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PULL_REQUEST_MERGED"
    }

    filter {
      type    = "BASE_REF"
      pattern = "^refs\\/heads\\/(${var.env})$"
    }

    filter {
      type    = "FILE_PATH"
      pattern = "^${var.deployment_directory}.*[.](tf|tfvars)$"
    }
  }
}

resource "aws_codebuild_webhook" "deploy_airflow_in_place" {
  project_name = aws_codebuild_project.deploy_airflow_in_place.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PULL_REQUEST_MERGED"
    }

    filter {
      type    = "BASE_REF"
      pattern = "^refs\\/heads\\/dev$"
    }

    filter {
      type    = "FILE_PATH"
      pattern = "^${var.airflow_deployment_directory}\\/.*"
    }
  }
}

resource "aws_codebuild_webhook" "airflow_docker_build" {
  project_name = aws_codebuild_project.airflow_docker_build.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PULL_REQUEST_MERGED"
    }

    filter {
      type    = "BASE_REF"
      pattern = "^refs\\/heads\\/(${var.env})$"
    }

    filter {
      type    = "FILE_PATH"
      pattern = "^${var.airflow_deployment_directory}\\/.+build\\.sh$"
    }

    filter {
      type    = "FILE_PATH"
      pattern = "^${var.airflow_deployment_directory}\\/.+Dockerfile$"
    }
  }
}

resource "aws_iam_role" "code_build" {
  count = var.create_codebuild_iam_role ? 1 : 0 
  name = "${var.resource_prefix}-codebuild-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "code_build_policy" {
  count = var.create_codebuild_iam_role ? 1 : 0 
  role   = aws_iam_role.code_build.name
  name   = "${var.resource_prefix}-codebuild-service-policy"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": "s3:*"
    },
    {
      "Effect": "Allow",
      "Resource": "arn:aws:codebuild:${var.region}:${var.aws_caller_user_id}:project/${var.resource_prefix}-*",
      "Action": "codebuild:*"
    },
    {
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ssm:${var.region}:${var.aws_caller_user_id}:parameter/${var.resource_prefix}-*"
      ],
      "Action": [
        "ssm:GetParameters",
        "ssm:GetParameter",
        "ssm:PutParameter",
        "ssm:ListTagsForResource"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": "arn:aws:ssm:${var.region}:${var.aws_caller_user_id}:*",
      "Action": "ssm:DescribeParameters"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "arn:aws:kms:${var.region}:${var.aws_caller_user_id}:alias/aws/ssm"
    },
    {
      "Effect": "Allow",
      "Resource": "arn:aws:ssm:${var.region}:${var.aws_caller_user_id}:association/*",
      "Action": "ssm:DescribeAssociation"
    },
    {
      "Effect": "Allow",
      "Resource":  [
          "arn:aws:ssm:${var.region}::document/AWS-UpdateSSMAgent",
          "arn:aws:ssm:${var.region}::document/AWS-RunShellScript",
          "arn:aws:ssm:${var.region}::document/AWS-ConfigureAWSPackage"
      ],
      "Action": [
          "ssm:GetDocument"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
        "arn:aws:iam::${var.aws_caller_user_id}:role/${var.resource_prefix}-*",
        "arn:aws:iam::${var.aws_caller_user_id}:policy//${var.resource_prefix}-*",
        "arn:aws:iam::${var.aws_caller_user_id}:instance-profile/${var.resource_prefix}-*"
      ],
      "Action": "iam:*"
    },
    {
      "Effect": "Allow",
      "Resource": "arn:aws:ecr:${var.region}:${var.aws_caller_user_id}:${var.resource_prefix}-*",
      "Action": "ecr:*"
    },
    {
    "Effect": "Allow",
    "Resource": "arn:aws:ecr:${var.region}:${var.aws_caller_user_id}:repository/${var.resource_prefix}-*",
    "Action": "ecr:*"
    },
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": "ecr:GetAuthorizationToken"
    },
    {
      "Effect": "Allow",
      "Resource": [
        "arn:aws:glue:${var.region}:${var.aws_caller_user_id}:catalog",
        "arn:aws:glue:${var.region}:${var.aws_caller_user_id}:database/default",
        "arn:aws:glue:${var.region}:${var.aws_caller_user_id}:crawler/${var.resource_prefix}-*",
        "arn:aws:glue:${var.region}:${var.aws_caller_user_id}:job/${var.resource_prefix}-*",
        "arn:aws:glue:${var.region}:${var.aws_caller_user_id}:database/${replace("${var.resource_prefix}-*", "-", "_")}"
      ],
      "Action": "glue:*"
    },
    {
      "Effect": "Allow",
      "Resource": [
        "arn:aws:athena:${var.region}:${var.aws_caller_user_id}:${var.resource_prefix}-*",
        "arn:aws:athena:${var.region}:${var.aws_caller_user_id}:workgroup/${var.resource_prefix}-*",
        "arn:aws:athena:${var.region}:${var.aws_caller_user_id}:workgroup/primary"
      ],
      "Action": "athena:*"
    },
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": "ec2:*"
    },
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": "rds:*"
    },
    {
      "Effect": "Allow",
      "Resource": "arn:aws:ec2:${var.region}:${var.aws_caller_user_id}:${var.resource_prefix}-*",
      "Action": "vpc:*"
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "tf_plan" {
  count = var.create_codebuild_terraform_plan_project == true ? 1 : 0
  name          = "${var.resource_prefix}-tf-plan"
  description   = "Perform terragrunt plan-all within deployment directory"
  build_timeout = "5"
  service_role  = var.codebuild_service_role_arn != null ? var.codebuild_service_role_arn : aws_iam_role.code_build[0].arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TG_ROOT_DIR"
      value = var.airflow_deployment_directory
    }

    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = var.terraform_version
    }

    environment_variable {
      name  = "TERRAGRUNT_VERSION"
      value = var.terragrunt_version
    }

    environment_variable {
      name  = "TF_IN_AUTOMATION"
      value = "true"
    }

    environment_variable {
      name  = "TF_INPUT"
      value = "false"
    }
  }
  
  dynamic "logs_config" {
    count = var.codebuild_terraform_plan_project_s3_log_path != null ? 1 : 0
    content {
      s3_logs {
        status   = "ENABLED"
        location = var.codebuild_terraform_plan_project_s3_log_path
      }
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_repo_url
    git_clone_depth = 1

    buildspec = var.codebuild_terraform_plan_project_buildspec

    git_submodules_config {
      fetch_submodules = false
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "tf_apply" {
  count = var.create_codebuild_terraform_apply_project == true ? 1 : 0
  name          = "${var.resource_prefix}-tf-apply"
  description   = "Perform terragrunt apply-all with auto-approve within deployment directory"
  build_timeout = "5"
  service_role  = var.codebuild_service_role_arn != null ? var.codebuild_service_role_arn : aws_iam_role.code_build[0].arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "TG_ROOT_DIR"
      value = var.airflow_deployment_directory
    }

    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = var.terraform_version
    }

    environment_variable {
      name  = "TERRAGRUNT_VERSION"
      value = var.terragrunt_version
    }

    environment_variable {
      name  = "TF_IN_AUTOMATION"
      value = "true"
    }

    environment_variable {
      name  = "TF_INPUT"
      value = "false"
    }
  }
  
  dynamic "logs_config" {
    count = var.codebuild_terraform_apply_project_s3_log_path != null ? 1 : 0
    content {
      s3_logs {
        status   = "ENABLED"
        location = var.codebuild_terraform_apply_project_s3_log_path
      }
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_repo_url
    git_clone_depth = 1

    buildspec = var.codebuild_terraform_apply_project_buildspec

    git_submodules_config {
      fetch_submodules = false
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "deploy_airflow_in_place" {
  name          = "${var.resource_prefix}-deploy_airflow"
  description   = "Triggers CodeDeploy deployment. Add or updates Airflow src in-place within target EC2 instances"
  build_timeout = "5"
  service_role  = var.codebuild_service_role_arn != null ? var.codebuild_service_role_arn : aws_iam_role.code_build[0].arn

  artifacts {
    type = "NO_ARTIFACTS"
  }
  source {
    type            = "GITHUB"
    location        = var.github_repo_url
    git_clone_depth = 1

    buildspec = var.codebuild_airflow_deployment_buildspec

    git_submodules_config {
      fetch_submodules = false
    }
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "APPLICATION_NAME"
      value = aws_codedeploy_app.airflow_src.name
    }

    environment_variable {
      name  = "BUCKET"
      value = aws_s3_bucket.private_bucket.id
    }

    environment_variable {
      name  = "DEPLOYMENT_CONFIG_NAME"
      value = aws_codedeploy_deployment_config.airflow.deployment_config_name
    }

    environment_variable {
      name  = "DEPLOYMENT_GROUP_NAME"
      value = aws_codedeploy_deployment_group.airflow.deployment_group_name
    }

    environment_variable {
      name  = "KEY"
      value = var.airflow_deployment_s3_key
    }

    environment_variable {
      name  = "SOURCE"
      value = var.deployment_directory
    }
  }

  dynamic "logs_config" {
    count = var.codebuild_airflow_deployment_project_s3_log_path != null ? 1 : 0
    content {
      s3_logs {
        status   = "ENABLED"
        location = var.codebuild_airflow_deployment_project_s3_log_path
      }
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "airflow_docker_build" {
  name          = "${var.resource_prefix}-airflow-build"
  description   = "Builds Airflow deployment image and pushes the image to ECR"
  build_timeout = "5"
  service_role  = aws_iam_role.code_build.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }
  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "ECR_REPO_URL"
      value = aws_ecr_repository.airflow.repository_url
    }
  }

  dynamic "logs_config" {
    count = var.codebuild_airflow_deployment_project_s3_log_path != null ? 1 : 0
    content {
      s3_logs {
        status   = "ENABLED"
        location = var.codebuild_airflow_deployment_project_s3_log_path
      }
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_repo_url
    git_clone_depth = 1

    buildspec = var.codebuild_airflow_deployment_project_buildspec
    git_submodules_config {
      fetch_submodules = false
    }
  }

  tags = var.tags
}

# resource "aws_codebuild_project" "dags_unit_tests" {
#   name          = "${var.resource_prefix}-airflow-apply"
#   description   = "Perform terraform apply with -auto-approve"
#   build_timeout = "5"
#   service_role  = aws_iam_role.code_build.arn

#   artifacts {
#     type = "NO_ARTIFACTS"
#   }

#   environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/standard:4.0"
#     type                        = "LINUX_CONTAINER"
#     image_pull_credentials_type = "CODEBUILD"

#     environment_variable {
#       name  = "TF_ROOT_DIR"
#       value = "deployment"
#     }
#   }


#   logs_config {
#     s3_logs {
#       status   = "ENABLED"
#       location = "${aws_s3_bucket.private_bucket.id}/CI_CD/terraform_apply"
#     }
#   }

#   source {
#     type            = "GITHUB"
#     location        = var.github_repo_url
#     git_clone_depth = 1

#     buildspec = "CI_CD/cfg/buildspec_tf_apply_batch.yml"

#     git_submodules_config {
#       fetch_submodules = false
#     }

#     # auth {
#     #   type = "OAUTH"
#     # }
#   }

#   tags = {
#     client     = "${var.client}"
#     project_id = "${var.project_id}"
#     terraform  = "true"
#     service    = "CI"
#     version    = "0.0.1"
#   }
# }


