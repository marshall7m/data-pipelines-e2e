resource "aws_iam_role_policy" "airflow_ssm" {
  count = var.create_airflow_instance && var.airflow_instance_ssm_access ? 1 : 0
  role = aws_iam_role.airflow[count.index].name
  name = "${var.resource_prefix}-ssm-ec2-access-users-policy"
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
                "arn:aws:ec2:*:*:instance/${data.}",
                "arn:aws:ssm:region:account-id:document/SSM-SessionManagerRunShell" 
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
                "arn:aws:ssm:*:*:session/${aws:username}-*"
            ]
        }
    ]
}