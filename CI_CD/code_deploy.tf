resource "aws_iam_role" "code_deploy" {
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
      "Resource": "arn:aws:ssm:region:account-id:parameter/${var.client}-${var.project_id}-*"
    },
    {
      "Effect": "Allow",
      "Action": "kms:Decrypt",
      "Resource": "arn:aws:kms:region:account-id:alias/aws/ssm"
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
  name             = "${local.resource_prefix}-cd-app"
}

resource "aws_codedeploy_deployment_config" "airflow_src" {
  deployment_config_name = "${local.resource_prefix}-cd-config"

  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 1
  }
}


resource "aws_codedeploy_deployment_group" "deploy_airflow_inplace" {
  app_name               = aws_codedeploy_app.airflow_src.name
  deployment_group_name  = "${local.resource_prefix}-in-place-cd-group"
  service_role_arn       = aws_iam_role.code_deploy.arn
  deployment_config_name = aws_codedeploy_deployment_config.airflow_src.id
  deployment_style {
      deployment_option = "WITHOUT_TRAFFIC_CONTROL"
      deployment_type = "IN_PLACE"
  }

  ec2_tag_filter {
    key   = "environment"
    type  = "KEY_AND_VALUE"
    value = "dev"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_STOP_ON_ALARM"]
  }
}

# resource "aws_codedeploy_deployment_group" "deploy_airflow_blue_green" {
#   app_name               = aws_codedeploy_app.airflow_src.name
#   deployment_group_name  = "${local.resource_prefix}-blue-green-cd-group"
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