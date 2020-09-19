locals {
  glue_crawlers_s3_access = var.glue_crawlers != [] && var.glue_role_arn != null ? var.glue_role_arn : [for crawler in var.glue_crawlers: concat("arn:aws:s3:::", regex("(?<=^(s3:\\/\\/)).+", crawler.s3_target.path))]
  glue_jobs_s3_access = var.glue_jobs != [] && var.glue_role_arn != null ? var.glue_role_arn : [for job in var.glue_jobs: concat("arn:aws:s3:::", regex("(?<=^(s3:\\/\\/)).+", job.default_arguments.output_dir))]
}

resource "aws_iam_role" "glue" {
    count =  var.glue_role_arn != null ? 1 : 0
    path = "/"
    name = "glue"
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

resource "aws_iam_role_policy" "aws_glue" {
  count = var.glue_role_arn != null ? 1 : 0
  role = aws_iam_role.airflow[count.index].name
  name = "${var.resource_prefix}-glue-policy"
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
      "Resource": ${local.glue_jobs_s3_access}
    },
    {
      "Effect": "Allow",
      "Action": [
          "s3:GetObject"
      ],
      "Resource": ${local.glue_crawlers_s3_access}
    },
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Resource": [
          
      ]
    }
  ]
}
POLICY
}

resource "aws_glue_job" "this" {
  for_each = {for job in var.glue_jobs:  job.name => job}

  name = "${var.env}-${each.key}"
  role_arn = var.glue_role_arn != null ? var.glue_role_arn : aws_iam_role.glue[0].arn
  command {
    script_location = each.value.script_location
  }

  default_arguments = {
    output_dir = each.value.default_arguments.output_dir
    catalog_database = each.value.default_arguments.catalog_database
    job-bookmark-option = lookup(each.value.default_arguments, "--job-bookmark-option", "job-bookmark-enable")
  }
  
  tags = each.value.tags
}
