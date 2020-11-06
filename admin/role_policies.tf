data "aws_iam_policy_document" "lead_developers" {
  statement {
    effect = "Allow"
    resources = ["*"]
    actions = var.full_access_actions

    dynamic "condition" {
      for_each = var.deployment_access_tags
      content {
        test = "StringEquals"
        variable = condition.key
        values = try(condition.value[*], list(condition.value))
      }
    }
  }
}

data "aws_iam_policy_document" "developers" {
  statement {
    effect = "Allow"
    resources = ["*"]
    actions = var.read_access_actions

    dynamic "condition" {
      for_each = var.deployment_access_tags
      content {
        test = "StringEquals"
        variable = condition.key
        values = try(condition.value[*], list(condition.value))
      }
    }
  }
}

resource "aws_iam_policy" "lead_developers" {
  name        = "lead_developers_access"
  path        = "/"
  description = "Full access to all deployments and their respective resources"

  policy = data.aws_iam_policy_document.lead_developers.json
}

resource "aws_iam_policy" "developers" {
  name        = "developers_access"
  path        = "/"
  description = "Read and write access to dev and staging deployments. Read access to prod deployments"

  policy = data.aws_iam_policy_document.developers.json
}


data "aws_iam_policy_document" "customers" {
  statement {
    effect = "Allow"
    resources = ["*"]
    actions = var.customer_actions

    dynamic "condition" {
      for_each = var.customer_access_tags
      content {
        test = "StringEquals"
        variable = condition.key
        values = try(condition.value[*], list(condition.value))
      }
    }
  }
}

resource "aws_iam_policy" "customers" {
  name        = "customer_s3_read_access"
  path        = "/"
  description = "Read only access exclusively for customer's s3 bucket"

  policy = data.aws_iam_policy_document.customers.json
} 

data "aws_iam_policy_document" "airflow_instance" {
  statement {
    effect = "Allow"
    resources = ["*"]
    actions = var.airflow_instance_actions

    dynamic "condition" {
      for_each = var.deployment_access_tags
      content {
        test = "StringEquals"
        variable = condition.key
        values = try(condition.value[*], list(condition.value))
      }
    }
  }
}

resource "aws_iam_policy" "airflow_instance" {
  name        = "airflow-ec2-policy"
  path        = "/"
  description = "Gives Airflow instance access to associated S3 bucket, ECR build images, and SSM parameter store values."

  policy = data.aws_iam_policy_document.airflow_instance.json
} 

resource "aws_iam_policy" "instance_ssm_access" {
  name        = "instance-state-manager-s3-accesspolicy"
  path        = "/"
  description = "Allows instance to retreive packages from managed AWS S3 buckets (e.g. used for: SSM agent, codedeploy agent, etc.)"

  policy = <<POLICY

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
          "arn:aws:s3:::aws-codedeploy-${var.region}/*",
          "arn:aws:s3:::aws-ssm-${var.region}/*",
          "arn:aws:s3:::aws-windows-downloads-${var.region}/*",
          "arn:aws:s3:::amazon-ssm-${var.region}/*",
          "arn:aws:s3:::amazon-ssm-packages-${var.region}/*",
          "arn:aws:s3:::${var.region}-birdwatcher-prod/*",
          "arn:aws:s3:::aws-ssm-distributor-file-${var.region}/*",
          "arn:aws:s3:::aws-ssm-document-attachments-${var.region}/*",
          "arn:aws:s3:::patch-baseline-snapshot-${var.region}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "limited_ssm_document_access" {
  name        = "ssm-limited-document-access"
  path        = "/"
  description = "Allows entity to get defined AWS owned documents from AWS System manager"

  policy = <<POLICY

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource":  [
          "arn:aws:ssm:${var.region}::document/AWS-UpdateSSMAgent",
          "arn:aws:ssm:${var.region}::document/AWS-RunShellScript",
          "arn:aws:ssm:${var.region}::document/AWS-ConfigureAWSPackage"
      ],
      "Action": [
          "ssm:GetDocument"
      ]
    }
  ]
}
POLICY
}

data "aws_iam_policy" "ssm_managed_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "codebuild_terraform" {
  statement {
    sid = "TerraformPlan"
    effect = "Allow"
    resources = ["*"]
    actions = var.read_access_actions

    dynamic "condition" {
      for_each = var.deployment_access_tags
      content {
        test = "StringEquals"
        variable = condition.key
        values = try(condition.value[*], list(condition.value))
      }
    }
  }
  statement {
    sid = "TerraformApply"
    effect = "Allow"
    resources = ["*"]
    actions = var.full_access_actions

    dynamic "condition" {
      for_each = var.deployment_access_tags
      content {
        test = "StringEquals"
        variable = condition.key
        values = try(condition.value[*], list(condition.value))
      }
    }
  }
  statement {
    sid = "SSMParameterStoreSecretAccess"
    effect = "Allow"
    actions = "kms:Decrypt"
    resources = ["arn:aws:kms:${var.region}:${var.aws_caller_user_id}:alias/aws/ssm"]
    
    dynamic "condition" {
      for_each = var.deployment_access_tags
      content {
        test = "StringEquals"
        variable = condition.key
        values = try(condition.value[*], list(condition.value))
      }
    }
  }
}

resource "aws_iam_policy" "codebuild_terraform" {
  name        = "airflow-ec2-policy"
  path        = "/"
  description = "Gives CodeBuild project access to resources within the same environment"

  policy = data.aws_iam_policy_document.codebuild_terraform.json
} 


resource "aws_iam_policy" "ssm_access" {
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ssm:${var.region}:${var.aws_caller_user_id}:parameter/${var.resource_prefix}-*"
      ],
      "Action": [
        "ssm:GetParameters",
        "ssm:GetParameter",
        "ssm:PutParameter",
        "ssm:ListTagsForResource"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": "arn:aws:ssm:${var.region}:${var.aws_caller_user_id}:*",
      "Action": "ssm:DescribeParameters"
    },
    
    {
      "Effect": "Allow",
      "Resource": "arn:aws:ssm:${var.region}:${var.aws_caller_user_id}:association/*",
      "Action": "ssm:DescribeAssociation"
    }
  ]
}
POLICY
}