resource "aws_iam_user" "user" {
  name = "learning-projects"
}

resource "aws_iam_user_policy_attachment" "data_pipeline" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.data_pipeline.arn
}

resource "aws_iam_user_policy_attachment" "instance_ssm_access" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.instance_ssm_access.arn
}

resource "aws_iam_policy" "data_pipeline" {
  name = "${var.client}-${var.project_id}-user-data-pipeline-policy"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:*",
                "cloudtrail:LookupEvents"
            ],
            "Resource": "*"
        },
        {
            "Action": "ec2:*",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "cloudwatch:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "cloudformation:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:*",
            "Resource": "*"
        },
        {
            "Action": [
                "codebuild:*",
                "events:DeleteRule",
                "events:DescribeRule",
                "events:DisableRule",
                "events:EnableRule",
                "events:ListTargetsByRule",
                "events:ListRuleNamesByTarget",
                "events:PutRule",
                "events:PutTargets",
                "events:RemoveTargets",
                "logs:GetLogEvents"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "logs:DeleteLogGroup"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:logs:*:*:log-group:/aws/codebuild/*:log-stream:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:StartSession"
            ],
            "Resource": "arn:aws:ecs:*:*:task/*/*"
        },
        {
            "Sid": "SNSTopicListAccess",
            "Effect": "Allow",
            "Action": [
                "sns:ListTopics",
                "sns:GetTopicAttributes"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        },
        {
            "Action": [
                "rds:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": "pi:*",
            "Effect": "Allow",
            "Resource": "arn:aws:pi:*:*:metrics/rds/*"
        },
        {
            "Action": "iam:CreateServiceLinkedRole",
            "Effect": "Allow",
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": [
                        "rds.amazonaws.com",
                        "rds.application-autoscaling.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:CreateAlias",
                "kms:CreateKey",
                "kms:DeleteAlias",
                "kms:Describe*",
                "kms:GenerateRandom",
                "kms:Get*",
                "kms:List*",
                "kms:TagResource",
                "kms:UntagResource",
                "iam:ListGroups",
                "iam:ListRoles",
                "iam:ListUsers"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Resource": "*",
            "Action": "ecs:*"
        },
        {
            "Effect": "Allow",
            "Action": "codedeploy:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ssm:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "codepipeline:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "codestar-connections:*"
            ],
            "Resource": "arn:aws:codestar-connections:us-west-2:501460770806:*"
        }
    ]
}
POLICY
}

resource "aws_iam_policy" "instance_ssm_access" {
  name = "${var.client}-${var.project_id}-user-instance-ssm-policy"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:StartSession"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:instance/${var.client}-${var.project_id}-*",
                "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:document/SSM-SessionManagerRunShell" 
            ],
            "Condition": {
                "BoolIfExists": {
                    "ssm:SessionDocumentAccessCheck": "true" 
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeSessions",
                "ssm:GetConnectionStatus",
                "ssm:DescribeInstanceProperties",
                "ec2:DescribeInstances"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:TerminateSession"
            ],
            "Resource": [
                "arn:aws:ssm:*:*:session/${data.aws_caller_identity.current.user_id}-*"
            ]
        }
    ]
}
POLICY
}