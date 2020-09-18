# resource "aws_eip_association" "eip_assoc" {
#   instance_id   = aws_instance.airflow_instance.id
#   allocation_id = aws_eip.airflow_instance.id
# }

# resource "aws_eip" "airflow_instance" {
#   # count = "${var.create_airflow_eip != false ? 1 : 0}"
#   vpc = true
#   public_ipv4_pool = "amazon"
#   instance = aws_instance.airflow_instance.id
#   tags = {
#     Name = "${var.resource_prefix}-airflow-ec2-eip"
#     type = "eip"
#     terraform = true
#     project = "${var.project_id}"
#     environment = "${var.env}"
#   }
# }

resource "aws_iam_role" "airflow_instance" {
  name = "${var.resource_prefix}-airflow-ec2-role"

  path = "/"
  
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "airflow_profile" {
  name = "${var.resource_prefix}-airflow-ec2-profile"
  role = aws_iam_role.airflow_instance.name
}

resource "aws_iam_role_policy" "airflow_instance" {
  role = aws_iam_role.airflow_instance.name
  name = "${var.resource_prefix}-airflow-ec2-policy"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.private_bucket}*"
      ],
      "Action": [
        "s3:Get*",
        "s3:List*",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:List*"
      ],
      "Resource": [
          "arn:aws:s3:::aws-codedeploy-us-west-2/*",
          "arn:aws:s3:::aws-ssm-us-west-2/*",
          "arn:aws:s3:::aws-windows-downloads-us-west-2/*",
          "arn:aws:s3:::amazon-ssm-us-west-2/*",
          "arn:aws:s3:::amazon-ssm-packages-us-west-2/*",
          "arn:aws:s3:::us-west-2-birdwatcher-prod/*",
          "arn:aws:s3:::aws-ssm-distributor-file-us-west-2/*",
          "arn:aws:s3:::aws-ssm-document-attachments-us-west-2/*",
          "arn:aws:s3:::patch-baseline-snapshot-us-west-2/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.airflow_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_instance" "airflow_instance" {
  for_each = {for instance in var.ec2_instances: instance.tags.Name => instance}
  associate_public_ip_address = lookup(each.value, "associate_public_ip_address", false)
  iam_instance_profile = aws_iam_instance_profile.airflow_profile.name
  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = [
    for sg_name in each.value.vpc_security_group_ids:
    aws_security_group.airflow_instance[sg_name].id
  ]

  key_name = lookup(each.value, "key_name", null)
  root_block_device {
    volume_size = 32
  }

  user_data = lookup(each.value, "user_data", null)

  tags = each.value.tags
  depends_on = [aws_security_group.airflow_instance]
}
 
resource "aws_security_group" "airflow_instance" {
  for_each = {for sg in var.ec2_security_groups: sg.name => sg}
  name        = each.key
  description = lookup(each.value, "description", null)
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = {for rule in each.value.ingress: "_" => rule}
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  
  dynamic "egress" {
    for_each = {for rule in each.value.egress: "_" => rule}
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}