output "ecr_repo_url" {
  value = "${aws_ecr_repository.airflow_local.repository_url}"
}

output "private_bucket_arn" {
  value = "${aws_s3_bucket.private_bucket.arn}"
}

output "private_bucket_name" {
  value = "${aws_s3_bucket.private_bucket.id}"
}