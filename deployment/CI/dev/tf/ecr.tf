resource "aws_ecr_repository" "main" {
  name                 = "sparkify_data_pipeline"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
