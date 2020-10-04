# resource "aws_codepipeline" "codepipeline" {
#   name     = "${var.project_id}-code-pipeline"
#   role_arn = aws_iam_role.codepipeline_role.arn

#   artifact_store {
#     location = var.private_bucket
#     type     = "S3"
#   }

#   # stage {
#   #   name = "Source"

#   #   dynamic "action" {
#   #     for_each = toset(var.env_list)
#   #     name             = "github-${each.value}-source"
#   #     category         = "Source"
#   #     owner            = "ThirdParty"
#   #     provider         = "GitHub"
#   #     version          = "1"
#   #     output_artifacts = ["github_${each.value}_source_output"]

#   #     configuration = {
#   #       Owner      = var.project_id
#   #       Repo       = "sparkify_end_to_end"
#   #       Branch     = ${each.value}
#   #     }
#   #   }
#   # }

#   stage {
#     name = "Build"

#     action {
#       name             = aws_codebuild_project.tf_validate_plan.name
#       category         = "Build"
#       owner            = "AWS"
#       provider         = "CodeBuild"
#       output_artifacts = ["tf_validate_plan_build_output"]
#       version          = "1"

#       configuration = {
#         ProjectName = aws_codebuild_project.tf_validate_plan.name
#         # EnvironmentVariables = {
#         #   name = "input_artifacts_dict"
#         #   value = {for env in var.env_list: env: "CODEBUILD_SRC_DIR_github_${env}_source_output"}
#         # }
#       }
#     }

#     action {
#       name             = aws_codebuild_project.tf_apply.name
#       category         = "Build"
#       owner            = "AWS"
#       provider         = "CodeBuild"
#       input_artifacts  = ["tf_validate_plan_build_output"]
#       version          = "1"

#       configuration = {
#         ProjectName = aws_codebuild_project.tf_apply.name
#       }
#     }

#     action {
#       name             = "Build"
#       category         = "Build"
#       owner            = "AWS"
#       provider         = "CodeBuild"
#       version          = "1"

#       configuration = {
#         ProjectName = aws_codebuild_project.airflow_docker_build.name
#       }
#     }

#     action {
#       name             = "dag_unit_tests"
#       category         = "Build"
#       owner            = "AWS"
#       provider         = "CodeBuild"
#       output_artifacts = ["${var.env}_dag_unit_test_output"]
#       version          = "1"

#       configuration = {
#         ProjectName = aws_codebuild_project.airflow_docker_build.name
#       }
#     }
#   }

#   stage {
#     name = "Deploy"

#     action {
#       name            = "Deploy"
#       category        = "Deploy"
#       owner           = "AWS"
#       provider        = "CodeDepoy"
#       input_artifacts = ["${var.env}_dag_unit_test_output"]
#       version         = "1"

#       configuration = {
#         ApplicationName = aws_codedeploy_app.airflow_src.name
#         DeploymentGroupName = aws_codedeploy_deployment_group.airflow.deployment_group_name
#       }
#     }
#   }
# }

# resource "aws_iam_role" "codepipeline_role" {
#   name = "test-role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "codepipeline.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy" "codepipeline_policy" {
#   name = "codepipeline_policy"
#   role = aws_iam_role.codepipeline_role.id

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect":"Allow",
#       "Action": [
#         "s3:GetObject",
#         "s3:GetObjectVersion",
#         "s3:GetBucketVersioning",
#         "s3:PutObject"
#       ],
#       "Resource": [
#         "${aws_s3_bucket.private_bucket.arn}",
#         "${aws_s3_bucket.private_bucket.arn}/*"
#       ]
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "codebuild:BatchGetBuilds",
#         "codebuild:StartBuild"
#       ],
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }