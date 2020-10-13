resource "aws_ecr_repository" "airflow_local" {
  name                 = "${local.resource_prefix}/airflow-local"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    client = var.client
    project_id = var.project_id
    terraform = true
    service = "CI_CD"
  }
  
}


resource "aws_ssm_parameter" "ecr_repo_url" {
  name  = "${aws_codedeploy_deployment_group.deploy_airflow_inplace.deployment_group_name}-ecr-repo-url"
  type  = "String"
  value = aws_ecr_repository.airflow_local.repository_url
  tags = {
    client = var.client
    project_id = var.project_id
    terraform = true
    service = "CI_CD"
  }
}