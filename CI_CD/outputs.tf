output "ecr_repo_url" {
  value = "${aws_ecr_repository.airflow_local.repository_url}"
}