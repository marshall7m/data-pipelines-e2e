resource "aws_glue_job" "process_raw" {
  name     = "${var.resource_prefix}-glue-job-process-raw"
  role_arn = aws_iam_role.glue.arn

  command {
    script_location = "s3://${var.private_bucket_name}/process_sparkify.py"
  }

  default_arguments = {
    output_dir          = "s3://${var.private_bucket_name}/data_pipeline/${var.env}/parquet_data/"
    catalog_database    = aws_glue_catalog_database.this.name
    job-bookmark-option = "job-bookmark-enable"
  }

  tags = merge(map(
    "task_id", "process_raw_glue_job",
    "dag_id", basename(path.cwd),
  ), var.tags)
}