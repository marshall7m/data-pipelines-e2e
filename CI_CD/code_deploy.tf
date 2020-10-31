resource "aws_iam_role" "code_deploy" {
  name = "${var.resource_prefix}-codedeploy-service-role"

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

resource "aws_iam_role_policy_attachment" "aws_code_deploy_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.code_deploy.name
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.code_deploy.name
  policy_arn = aws_iam_policy.appspec_policy.arn
}

resource "aws_iam_policy" "appspec_policy" {
  name        = "${var.client}-${var.project_id}-CodeDeploy-Appspec-AWS-Access"
  path        = "/"
  description = "Allows CodeDeploy appspec.yml to access have access to necessary AWS services associated with project"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject*"
      ],
      "Resource": "${aws_s3_bucket.private_bucket.arn}"
    },
    {
      "Effect": "Allow",
      "Action": "codedeploy:*",
      "Resource": "arn:aws:codedeploy:${var.region}:${var.aws_caller_user_id}:*/${var.client}-${var.project_id}-*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "codedeploy_ssm_ps_access" {
  name        = "${var.client}-${var.project_id}-CodeDeploy-SSM-PS-Read-Access"
  path        = "/"
  description = "Allows CodeDeploy to access SSM Parameter values associated with project"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ssm:DescribeParameters",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ssm:GetParameters",
      "Resource": "arn:aws:ssm:${var.region}:${var.aws_caller_user_id}:parameter/${var.client}-${var.project_id}-*"
    },
    {
      "Effect": "Allow",
      "Action": "kms:Decrypt",
      "Resource": "arn:aws:kms:${var.region}:${var.aws_caller_user_id}:alias/aws/ssm"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "CodeDeploy-SSM-PS-Read-Access" {
  policy_arn = aws_iam_policy.codedeploy_ssm_ps_access.arn
  role       = aws_iam_role.code_deploy.name
}

resource "aws_codedeploy_app" "airflow_src" {
  compute_platform = "Server"
  name             = var.cd_app_name != null ? var.cd_app_name : local.resource_prefix
}

resource "aws_codedeploy_deployment_config" "airflow_src" {
  deployment_config_name = "${var.resource_prefix}-cd-config"

  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 0
  }
}


resource "aws_codedeploy_deployment_group" "airflow" {
  app_name               = aws_codedeploy_app.airflow_src.name
  deployment_group_name  = var.deployment_group_name
  service_role_arn       = aws_iam_role.code_deploy.arn
  deployment_config_name = aws_codedeploy_deployment_config.airflow_src.id
  deployment_style {
      deployment_option = "WITHOUT_TRAFFIC_CONTROL"
      deployment_type = "IN_PLACE"
  }

  dynamic "ec2_tag_set" {
    for_each = var.ec2_tag_set_list != null ? toset(var.ec2_tag_set_list) : 0
    dynamic "ec2_tag_filter" {
      for_each = ec2_tag_set.value
      content = {
        key = ec2_tag_filter.value.key
        type = coalesce(
          "${ec2_tag_filter.value.key != null && ec2_tag_filter.value.value != null ? "KEY_AND_VALUE" : null}",
          "${ec2_tag_filter.value.key != null && ec2_tag_filter.value.value == null ? "KEY_ONLY" : null}",
          "${ec2_tag_filter.value.key == null && ec2_tag_filter.value.value != null ? "VALUE_ONLY" : null}"
        )
        value = ec2_tag_filter.value.value
      }
    }
  }

  dynamic "ec2_tag_filter" {
    for_each = var.ec2_tag_filters != null ? var.ec2_tag_filters : 0
    content = {
      key = each.value.key
      type = coalesce(
        "${ec2_tag_filter.value.key != null && ec2_tag_filter.value.value != null ? "KEY_AND_VALUE" : null}",
        "${ec2_tag_filter.value.key != null && ec2_tag_filter.value.value == null ? "KEY_ONLY" : null}",
        "${ec2_tag_filter.value.key == null && ec2_tag_filter.value.value != null ? "VALUE_ONLY" : null}"
      )
      value = each.value.value
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_STOP_ON_ALARM"]
  }
}

# resource "aws_codedeploy_deployment_group" "deploy_airflow_blue_green" {
#   app_name               = aws_codedeploy_app.airflow_src.name
#   deployment_group_name  = "${var.resource_prefix}-blue-green-cd-group"
#   service_role_arn       = aws_iam_role.code_deploy.arn
#   deployment_config_name = aws_codedeploy_deployment_config.airflow_src.id
  
#   deployment_style {
#       deployment_option = "WITH_TRAFFIC_CONTROL"
#       deployment_type = "BLUE_GREEN"
#   }
  
#   load_balancer_info {
#     elb_info {
#       name = aws_elb.deploy_airflow_blue_green.name
#     }
#   }

#   blue_green_deployment_config {
#     deployment_ready_option {
#       action_on_timeout    = "STOP_DEPLOYMENT"
#       wait_time_in_minutes = 60
#     }

#     green_fleet_provisioning_option {
#       action = "DISCOVER_EXISTING"
#     }

#     terminate_blue_instances_on_deployment_success {
#       action = "KEEP_ALIVE"
#     }
#   }

#   ec2_tag_filter {
#     key   = "environment"
#     type  = "KEY_AND_VALUE"
#     value = "prod"
#   }

#   auto_rollback_configuration {
#     enabled = true
#     events  = ["DEPLOYMENT_STOP_ON_ALARM"]
#   }
# }

# resource "aws_elb" "deploy_airflow_blue_green" {

# }