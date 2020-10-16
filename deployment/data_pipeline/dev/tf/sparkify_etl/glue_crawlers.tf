resource "aws_iam_role" "glue" {
    path = "/"
    name = "${local.resource_prefix}-glue-crawler"
    description = "Allows all glue crawlers to read access and all glue jobs read/write access to the appropriate S3 resources."
    assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "glue.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    EOF
}

resource "aws_iam_role_policy" "glue" {
  role = aws_iam_role.glue.name
  name = "${local.resource_prefix}-glue-policy"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [   
    {
      "Effect": "Allow",
      "Action": [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
      ],
      "Resource": "${data.terraform_remote_state.CI_CD.outputs.private_bucket_arn}/*"
    },
    {
      "Effect": "Allow",
      "Action": [
          "s3:GetObject"
      ],
      "Resource": "${data.terraform_remote_state.CI_CD.outputs.private_bucket_arn}/*"
    },
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_glue_catalog_database" "this" {
  name = "${replace(local.resource_prefix, "-", "_")}_db"
}

resource "aws_glue_crawler" "raw" {
  database_name = aws_glue_catalog_database.this.name
  name          = "${local.resource_prefix}-glue-crawler-raw"
  role          = aws_iam_role.glue.arn

  s3_target {
    path = "{s3://${data.terraform_remote_state.CI_CD.outputs.private_bucket_name}/source_data/raw/staging_events/"
  }

  s3_target {
    path = "{s3://${data.terraform_remote_state.CI_CD.outputs.private_bucket_name}/data_pipeline/data/raw/staging_songs/"
  }

  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "DEPRECATE_IN_DATABASE"
  }

  tags = {
      "environment" = var.env 
      "project_id" = var.project_id
      "client" = var.client
      "service" = "data-pipeline"
      "task_id" = "crawl_raw_sources"
      "dag_id" = "sparkify_analytics"
  }
}

resource "aws_glue_crawler" "parquet" {
  database_name = aws_glue_catalog_database.this.name
  name          = "${local.resource_prefix}-glue-crawler-parquet"
  role          = aws_iam_role.glue.arn

  s3_target {
    path = "s3://${data.terraform_remote_state.CI_CD.outputs.private_bucket_name}/data_pipeline/data/parquet/year={year}/month={month}/day={day}/"
  }

  schema_change_policy {
        update_behavior = "UPDATE_IN_DATABASE"
        delete_behavior = "DEPRECATE_IN_DATABASE"
    }

  tags = {
      "environment" = var.env 
      "project_id" = var.project_id
      "client" = var.client
      "service" = "data-pipeline"
      "task_id" = "crawl_parquet_sources"
      "dag_id" = "sparkify_analytics"
  }
}