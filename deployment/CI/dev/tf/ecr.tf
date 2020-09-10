resource "aws_ecr_repository" "main" {
  name                 = "${var.client}/${var.project_id}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


