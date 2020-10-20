resource "aws_codebuild_webhook" "tf_pr" {
  project_name = aws_codebuild_project.tf_validate_plan.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH,PULL_REQUEST_CREATED,PULL_REQUEST_UPDATED"
    }

    filter {
      type    = "FILE_PATH"
      pattern = "^.*[.](tf|tfvars)$"
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
      pattern = "^refs\\/heads\\/(dev|prod)$"
    }

    filter {
      type    = "FILE_PATH"
      pattern = "^.*[.](tf|tfvars)$"
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
      pattern = "^.*\\/data_pipeline\\/dev\\/src\\/.*"
    }
  }
}

# resource "aws_codebuild_webhook" "deploy_airflow_blue_green" {
#   project_name = aws_codebuild_project.deploy_airflow_blue_green.name

#   filter_group {
#     filter {
#       type    = "EVENT"
#       pattern = "PULL_REQUEST_MERGED"
#     }

#     filter {
#       type    = "BASE_REF"
#       pattern = "^refs\\/heads\\/prod$"
#     }

#     filter {
#       type    = "FILE_PATH"
#       pattern = "^.*\\/data_pipeline\\/dev\\/src\\/.*"
#     }
#   }
# }

resource "aws_codebuild_webhook" "airflow_docker_build" {
  project_name = aws_codebuild_project.airflow_docker_build.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PULL_REQUEST_MERGED"
    }

    filter {
      type    = "BASE_REF"
      pattern = "^refs\\/heads\\/(dev|prod)$"
    }

    filter {
      type    = "FILE_PATH"
      pattern = "^deployment\\/data_pipeline\\/.+build\\.sh$"
    }

    filter {
      type    = "FILE_PATH"
      pattern = "^deployment\\/data_pipeline\\/.+Dockerfile$"
    }
  }
}

resource "aws_iam_role" "code_build" {
  name = "${var.resource_prefix}-AWSCodeBuildServiceRole"

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
  role   = aws_iam_role.code_build.name
  name   = "${var.resource_prefix}-AWSCodeBuildServicePolicy"
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
      "Resource": "arn:aws:ecr:${var.region}:${var.aws_caller_user_id}:${var.client}-*",
      "Action": "ecr:*"
    },
    {
    "Effect": "Allow",
    "Resource": "arn:aws:ecr:${var.region}:${var.aws_caller_user_id}:repository/${var.client}-*",
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

resource "aws_codebuild_project" "tf_validate_plan" {
  name          = "${var.resource_prefix}-tf-validate-plan"
  description   = "Perform terraform plan and terraform validator"
  build_timeout = "5"
  service_role  = aws_iam_role.code_build.arn

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
      value = "deployment"
    }

    environment_variable {
      name  = "LIVE_BRANCHES"
      value = "(dev, prod)"
    }

    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = "0.12.28"
    }

    environment_variable {
      name  = "TERRAGRUNT_VERSION"
      value = "0.25.4"
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

  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.private_bucket.id}/CI_CD/terraform_validate_plan"
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_repo_url
    git_clone_depth = 1

    # auth {
    #   type = "OAUTH"
    # }

    buildspec = "CI_CD/cfg/buildspec_terraform_validate_plan.yml"
    git_submodules_config {
      fetch_submodules = false
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "tf_apply" {
  name          = "${var.resource_prefix}-tf-apply"
  description   = "Perform terraform apply with -auto-approve"
  build_timeout = "5"
  service_role  = aws_iam_role.code_build.arn

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
      name  = "TF_ROOT_DIR"
      value = "deployment"
    }

    environment_variable {
      name  = "LIVE_BRANCHES"
      value = "(dev, prod)"
    }

    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = "0.12.28"
    }

    environment_variable {
      name  = "TF_IN_AUTOMATION"
      value = "true"
    }

    environment_variable {
      name  = "TF_CLI_ARGS"
      value = "-input=false"
    }
  }


  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.private_bucket.id}/CI_CD/terraform_apply"
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_repo_url
    git_clone_depth = 1

    buildspec = "CI_CD/cfg/buildspec_tf_apply.yml"

    git_submodules_config {
      fetch_submodules = false
    }

    # auth {
    #   type = "OAUTH"
    # }
  }

  tags = var.tags
}

# resource "aws_codebuild_project" "deploy_airflow_blue_green" {
#   name          = "deploy_airflow"
#   description   = "Triggers CodeDeploy deployment to add or update Airflow src within EC2 instances"
#   build_timeout = "5"
#   service_role  = aws_iam_role.code_build.arn

#   artifacts {
#     type = "NO_ARTIFACTS"
#   }

#   source {
#     type            = "GITHUB"
#     location        = var.github_repo_url
#     git_clone_depth = 1

#     buildspec = "deployment/CI/dev/cfg/buildspec_deploy_airflow.yml"

#     git_submodules_config {
#       fetch_submodules = false
#     }
#   }

#   environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/standard:4.0"
#     type                        = "LINUX_CONTAINER"
#     image_pull_credentials_type = "CODEBUILD"
#     privileged_mode             = true

#     environment_variable {
#       name  = "APPLICATION_NAME"
#       value = aws_codedeploy_app.airflow_src.name
#     }

#     environment_variable {
#       name  = "BUCKET"
#       value = aws_s3_bucket.private_bucket.id
#     }

#     environment_variable {
#       name  = "DEPLOYMENT_CONFIG_NAME"
#       value = aws_codedeploy_deployment_config.airflow_src.deployment_config_id
#     }

#     environment_variable {
#       name  = "DEPLOYMENT_GROUP_NAME"
#       value = aws_codedeploy_deployment_group.deploy_airflow_blue_green.id
#     }

#     environment_variable {
#       name  = "KEY"
#       value = "data_pipeline/prod/src/"
#     }

#     environment_variable {
#       name  = "SOURCE"
#       value = "deployment/data_pipeline/prod/src/"
#     }
#   }

#   logs_config {
#     s3_logs {
#       status   = "ENABLED"
#       location = "${aws_s3_bucket.private_bucket.id}/CI/dev/deploy_airflow_blue_green/logs"
#     }
#   }

#   tags = {
#     client = "${var.client}"
#     project_id = "${var.project_id}"
#     terraform   = "true"
#     service     = "CI"
#     version     = "0.0.1"
#   }
# }

resource "aws_codebuild_project" "deploy_airflow_in_place" {
  name          = "${var.resource_prefix}-deploy_airflow"
  description   = "Triggers CodeDeploy deployment. Add or updates Airflow src in-place within target EC2 instances"
  build_timeout = "5"
  service_role  = aws_iam_role.code_build.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }
  source {
    type            = "GITHUB"
    location        = var.github_repo_url
    git_clone_depth = 1

    buildspec = "CI_CD/cfg/buildspec_deploy_airflow.yml"

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
      value = aws_codedeploy_deployment_config.airflow_src.deployment_config_name
    }

    environment_variable {
      name  = "DEPLOYMENT_GROUP_NAME"
      value = aws_codedeploy_deployment_group.deploy_airflow_inplace.deployment_group_name
    }

    environment_variable {
      name  = "KEY"
      value = "data_pipeline/dev/src/"
    }

    environment_variable {
      name  = "SOURCE"
      value = "deployment/data_pipeline/dev/"
    }
  }

  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.private_bucket.id}/CI_CD/dev/deploy_airflow_in_place/logs"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "airflow_docker_build" {
  name          = "${var.resource_prefix}-airflow-build"
  description   = "Compiles DAG dependencies and project DAGs into a Docker image and pushes the image to ECR"
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
      value = aws_ecr_repository.airflow_local.repository_url
    }
  }

  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.private_bucket.id}/CI_CD/docker_build/logs"
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_repo_url
    git_clone_depth = 1

    buildspec = "CI_CD/cfg/buildspec_docker_build.yml"
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

# resource "aws_codebuild_project" "airflow_batch_build" {
#   name          = "airflow_batch_build"
#   description   = "Compiles Airflow from source, DAG dependencies and project DAGs into a Docker image and pushes the image to ECR"
#   build_timeout = "5"
#   service_role  = aws_iam_role.code_build.arn

# artifacts {
#   type = "NO_ARTIFACTS"
# }
#   cache {
#     type  = "LOCAL"
#     modes = ["LOCAL_DOCKER_LAYER_CACHE"]
#   }
#   environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/standard:4.0"
#     type                        = "LINUX_CONTAINER"
#     image_pull_credentials_type = "CODEBUILD"
#     privileged_mode             = true

#     environment_variable {
#       name  = "ECR_REPO_URL"
#       value = aws_ecr_repository.main.repository_url
#     }

#     environment_variable {
#       name  = "IMAGE_REPO_NAME"
#       value = aws_ecr_repository.main.name
#     }

#     environment_variable {
#       name  = "IMAGE_TAG"
#       value = "latest"
#     }
#   }

#   logs_config {
#     s3_logs {
#       status   = "ENABLED"
#       location = "${aws_s3_bucket.private_bucket.id}/CI/dev/docker_build/logs"
#     }
#   }

#   source {
#     type            = "GITHUB"
#     location        = var.github_repo_url
#     git_clone_depth = 1

#     buildspec = "deployment/CI/dev/cfg/buildspec_airflow_batch.yml"
#     git_submodules_config {
#       fetch_submodules = false
#     }
#   }

#   tags = {
#     client = "${var.client}"
#     project_id = "${var.project_id}"
#     environment = "${var.env}"
#     terraform   = "true"
#     service     = "CI"
#     version     = "0.0.1"
#   }
# }


