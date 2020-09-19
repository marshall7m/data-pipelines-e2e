locals {
  default_airflow_instance_tags = {
    "Name" = "${var.resource_prefix}-airflow-ec2"
    "instance_type" = "${var.airflow_instance_type}"  
    "terraform" = true
  }
  airflow_instance_tags = var.create_airflow_instance == true && var.airflow_instance_tags != {} ? var.airflow_instance_tags : local.default_airflow_instance_tags
}

resource "aws_instance" "airflow" {
  count = var.create_airflow_instance == true && var.airflow_instance_ami != null && var.airflow_instance_type != null && length(var.private_subnets_ids) > 0 ? 1 : 0
  associate_public_ip_address = false
  iam_instance_profile = aws_iam_instance_profile.airflow[count.index].name
  ami                         = var.airflow_instance_ami
  instance_type               = var.airflow_instance_type
  subnet_id                   = var.airflow_instance_subnet_id != null ? var.airflow_instance_subnet_id : var.private_subnets_ids[0]
  vpc_security_group_ids      = [aws_security_group.airflow[count.index].id]

  key_name = var.airflow_instance_key_name
  root_block_device {
    volume_size = 32
  }

  user_data = var.airflow_instance_user_data

  tags = local.airflow_instance_tags
}
 
resource "aws_security_group" "airflow" {
  count = var.create_airflow_instance == true && var.create_airflow_instance_sg == true ? 1 : 0
  name        = "${var.resource_prefix}-airflow-ec2-sg"
  description = "Default security group for airflow instance and postgres meta-db"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.private_subnets_cidr_blocks
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.private_subnets_cidr_blocks
  }

  dynamic "ingress" {
    for_each = var.airflow_instance_ssh_cidr_blocks != [] && var.airflow_instance_key_name != null ? [count.index] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.airflow_instance_ssh_cidr_blocks
    } 
  } 

  dynamic "egress" {
    for_each = var.airflow_instance_ssh_cidr_blocks != [] && var.airflow_instance_key_name != null ? [count.index] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.airflow_instance_ssh_cidr_blocks
    } 
  }
}

resource "aws_iam_role" "airflow" {
  count = var.create_airflow_instance ? 1 : 0
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

resource "aws_iam_instance_profile" "airflow" {
  count = var.create_airflow_instance ? 1 : 0
  name = "${var.resource_prefix}-airflow-ec2-profile"
  role = aws_iam_role.airflow[count.index].name
}

resource "aws_iam_role_policy" "airflow" {
  count = var.create_airflow_instance ? 1 : 0
  role = aws_iam_role.airflow[count.index].name
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
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "airflow_ssm" {
  count = var.create_airflow_instance && var.airflow_instance_ssm_access ? 1 : 0
  role = aws_iam_role.airflow[count.index].name
  name = "${var.resource_prefix}-airflow-ssm-ec2-access-policy"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
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
  count = var.create_airflow_instance && var.airflow_instance_ssm_access ? 1 : 0
  role       = aws_iam_role.airflow[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_db_subnet_group" "airflow" {
  count = var.create_airflow_db == true && length(var.private_subnets_ids) > 0 ? 1 : 0
  name        = "${var.resource_prefix}-airflow-db-subnet-group"
  description = "List of subnets ids to be used to host databases stored on AWS RDS"
  subnet_ids  = var.private_subnets_ids
}

resource "aws_db_instance" "airflow" {
  count = var.create_airflow_db == true && var.airflow_db_name != null && var.airflow_db_username != null && var.airflow_db_password != null && var.airflow_db_instance_class != null ? 1 : 0
  identifier                = "${var.resource_prefix}-meta-db"
  allocated_storage         = var.airflow_db_allocated_storage
  engine                    = "postgres"
  engine_version            = "9.6.6"
  instance_class            = var.airflow_db_instance_class
  name                      = var.airflow_db_name
  username                  = var.airflow_db_username
  password                  = var.airflow_db_password
  storage_type              = "gp2"
  backup_retention_period   = 14
  multi_az                  = true
  publicly_accessible       = false
  apply_immediately         = true
  db_subnet_group_name      = aws_db_subnet_group.airflow[count.index].name
  final_snapshot_identifier = "${var.resource_prefix}-meta-db-final-snapshot"
  skip_final_snapshot       = false
  vpc_security_group_ids      = [aws_security_group.airflow[count.index].id]
  port                      = "5432"
}