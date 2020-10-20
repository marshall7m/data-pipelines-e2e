output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "client" {
  value = var.client
}

output "ecr_repo_url" {
  value = "${aws_ecr_repository.airflow_local.repository_url}"
}

output "private_bucket_name" {
  value = "${aws_s3_bucket.private_bucket.id}"
}

output "private_bucket_arn" {
  value = "${aws_s3_bucket.private_bucket.arn}"
}

output "tf_state_bucket_name" {
  description = "S3 bucket used to store tf state files. If tf_state_bucket isn't defined then the tf state files are assumed to stored in the private bucket."
  value = "${coalesce(var.private_bucket_name, var.tf_state_bucket_name)}"
}

output "tf_state_bucket_arn" {
  description = "S3 bucket ARN used to store tf state files. If tf_state_bucket isn't defined then the tf state files are assumed to stored in the private bucket and the private bucket ARN is used"
  value = "${var.tf_state_bucket_name!= var.private_bucket_name? aws_s3_bucket.tf_state_bucket[0].arn : aws_s3_bucket.private_bucket.arn}"
}