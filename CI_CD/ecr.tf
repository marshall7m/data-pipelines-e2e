resource "aws_ecr_repository" "airflow" {
  name                 = "${var.ecr_base_domain}/${aws_codedeploy_deployment_group.airflow.deployment_group_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
  
}


resource "aws_ssm_parameter" "ecr_repo_url" {
  name  = "${aws_codedeploy_deployment_group.airflow.deployment_group_name}-ecr-repo-url"
  type  = "SecureString"
  value = aws_ecr_repository.airflow.repository_url
  tags = var.tags
}