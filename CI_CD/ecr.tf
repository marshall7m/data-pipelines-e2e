resource "aws_ecr_repository" "airflow_local" {
  name                 =  "${var.client}/${var.project_id}/airflow-local"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


