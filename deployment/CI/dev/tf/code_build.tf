provider "aws" {
  region  = "us-west-2"
}
resource "aws_codebuild_webhook" "tf_pr" {
  project_name = aws_codebuild_project.tf_validate_plan.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH,PULL_REQUEST_CREATED,PULL_REQUEST_UPDATED"
    }

    filter {
      type = "FILE_PATH"
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
      type = "FILE_PATH"
      pattern = "^.*[.](tf|tfvars)$"
    }
  }
}

resource "aws_codebuild_webhook" "docker_build" {
  project_name = aws_codebuild_project.docker_build.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PULL_REQUEST_MERGED"
    }

    filter {
      type = "FILE_PATH"
      pattern = "^Dockerfile$"
    }
  }
}

resource "aws_iam_role" "code_build" {
  name = "sparkify_code_build_role"

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
  role = aws_iam_role.code_build.name
  name = "SparkifyAWSCodeBuildServicePolicy"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": 
  [
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
      "Action": [
        "s3:*"
        
      ],
      "Resource": [
        "arn:aws:s3:::${var.base_bucket}*"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
      ]
    }
  ]
} 
POLICY
}

resource "aws_codebuild_project" "tf_validate_plan" {
  name          = "terraform_validate_plan"
  description   = "Perform terraform plan and terraform validator"
  build_timeout = "5"
  service_role  = aws_iam_role.code_build.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.12.28"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_ROOT_DIR"
      value = "deployment"
    }

    environment_variable {
      name  = "LIVE_BRANCHES"
      value = "(dev, prod)"
    }
  }

  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${var.base_bucket}/CI/dev/terraform_validate_plan"
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_repo_url
    git_clone_depth = 1

    buildspec = "deployment/CI/dev/cfg/buildspec_terraform_validate_plan.yml"
    git_submodules_config {
      fetch_submodules = false
    }
  }

  tags = {
    Environment = "dev"
    Terraform = "true"
    Service = "CI"
    Version = "0.0.1"
  }
}

resource "aws_codebuild_project" "tf_apply" {
  name          = "terraform_apply"
  description   = "Perform terraform apply with -auto-approve"
  build_timeout = "5"
  service_role  = aws_iam_role.code_build.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.12.28"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "LIVE_BRANCHES"
      value = "(dev, prod)"
    }
  }
  
  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${var.base_bucket}/CI/dev/terraform_apply"
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_repo_url
    git_clone_depth = 1

    buildspec = "deployment/CI/dev/cfg/buildspec_terraform_apply.yml"
    git_submodules_config {
      fetch_submodules = false
    }
  }

  tags = {
        Environment = "dev"
        Terraform = "true"
        Service = "CI"
        Version = "0.0.1"
  }
}

resource "aws_codebuild_project" "docker_build" {
  name          = "docker_build"
  description   = "Build Dockerfile from Github source and push to ECR"
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
    privileged_mode = true

    environment_variable {
      name  = "ECR_REPO_URL"
      value = aws_ecr_repository.main.repository_url
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.main.name
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "BRANCH_NAME_latest"
    }
  }
  
  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${var.base_bucket}/CI/dev/docker_build"
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_repo_url
    git_clone_depth = 1

    buildspec = "deployment/CI/dev/cfg/buildspec_docker_build.yml"
    git_submodules_config {
      fetch_submodules = false
    }
  }

  tags = {
        Environment = "dev"
        Terraform = "true"
        Service = "CI"
        Version = "0.0.1"
  }
}