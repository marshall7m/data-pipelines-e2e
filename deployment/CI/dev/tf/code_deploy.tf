resource "aws_iam_role" "airflow_src" {
  name = "${local.resource_prefix}-AWSCodeDeployServiceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.code_deploy.name
}

resource "aws_codedeploy_app" "airflow_src" {
  compute_platform = "Server"
  name             = "${local.resource_prefix}-cd-app"
}

resource "aws_codedeploy_deployment_config" "airflow_src" {
  deployment_config_name = "${local.resource_prefix}-cd-config"

  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 2
  }
}

resource "aws_codedeploy_deployment_group" "foo" {
  app_name               = aws_codedeploy_app.airflow_src.name
  deployment_group_name  = "${local.resource_prefix}-cd-group"
  service_role_arn       = aws_iam_role.airflow_src.arn
  deployment_config_name = aws_codedeploy_deployment_config.airflow_src.id
  deployment_style = {
      deployment_options = "WITHOUT_TRAFFIC_CONTROL"
      type = "BLUE_GREEN"
  }
#   ec2_tag_filter {
#     key   = "filterkey"
#     type  = "KEY_AND_VALUE"
#     value = "filtervalue"
#   }

#   trigger_configuration {
#     trigger_events     = ["DeploymentFailure"]
#     trigger_name       = "foo-trigger"
#     trigger_target_arn = "foo-topic-arn"
#   }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_STOP_ON_ALARM"]
  }

#   alarm_configuration {
#     alarms  = ["my-alarm-name"]
#     enabled = true
#   }
}