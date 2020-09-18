resource "aws_iam_role" "glue" {
    path = "/"
    name = "glue"
    description = "Allows ALL Glue Crawlers to call needed AWS services."
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
resource "aws_iam_role_policy_attachment" "AWSGlueServiceRole" {
  role = aws_iam_role.glue.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_glue_job" "jobs" {
  for_each = {for job in var.glue_jobs:  job.name => job}

  name = "${var.env}-${each.key}"
  role_arn = aws_iam_role.glue.arn
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
