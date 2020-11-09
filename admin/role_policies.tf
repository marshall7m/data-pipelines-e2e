

data "aws_iam_policy_document" "airflow_instance" {
  statement {
    effect = "Allow"
    resources = ["*"]
    actions = var.airflow_instance_actions
  }
}

resource "aws_iam_policy" "airflow_instance" {
  name        = "airflow-ec2-policy"
  path        = "/"
  description = "Gives Airflow instance access to associated S3 bucket, ECR build images, and SSM parameter store values."

  policy = data.aws_iam_policy_document.airflow_instance.json
} 


data "aws_iam_policy_document" "instance_ssm_access" {
  for_each = toset(local.aws_provider_aliases)
  statement {
    effect = "Allow"
    resources = ["*"]
    actions = [
      "arn:aws:s3:::aws-codedeploy-${data.aws_region.current[each.value].name}/*",
      "arn:aws:s3:::aws-ssm-${data.aws_region.current[each.value].name}/*",
      "arn:aws:s3:::aws-windows-downloads-${data.aws_region.current[each.value].name}/*",
      "arn:aws:s3:::amazon-ssm-${data.aws_region.current[each.value].name}/*",
      "arn:aws:s3:::amazon-ssm-packages-${data.aws_region.current[each.value].name}/*",
      "arn:aws:s3:::${data.aws_region.current[each.value].name}-birdwatcher-prod/*",
      "arn:aws:s3:::aws-ssm-distributor-file-${data.aws_region.current[each.value].name}/*",
      "arn:aws:s3:::aws-ssm-document-attachments-${data.aws_region.current[each.value].name}/*",
      "arn:aws:s3:::patch-baseline-snapshot-${data.aws_region.current[each.value].name}/*"
    ]
  }
}

resource "aws_iam_policy" "instance_ssm_access" {
  name        = "instance-state-manager-s3-accesspolicy"
  path        = "/"
  description = "Allows instance to retreive packages from managed AWS S3 buckets (e.g. used for: SSM agent, codedeploy agent, etc.)"
  policy = data.aws_iam_policy_document.airflow_instance.json
}

data "aws_iam_policy_document" "limited_ssm_document_access" {
  for_each = toset(local.aws_provider_aliases)
  statement {
    effect = "Allow"
    resources = ["*"]
    actions = [
      "arn:aws:ssm:${data.aws_region.current[each.value].name}::document/AWS-UpdateSSMAgent",
      "arn:aws:ssm:${data.aws_region.current[each.value].name}::document/AWS-RunShellScript",
      "arn:aws:ssm:${data.aws_region.current[each.value].name}::document/AWS-ConfigureAWSPackage"
    ]
  }
}

resource "aws_iam_policy" "limited_ssm_document_access" {
  for_each = toset(local.aws_provider_aliases)
  name        = "ssm-limited-document-access"
  path        = "/"
  description = "Allows entity to get defined AWS owned documents from AWS System manager"

  policy = data.aws_iam_policy_document.limited_ssm_document_access[each.value].json
}

data "aws_iam_policy" "ssm_managed_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "codebuild_terraform" {
  for_each = toset(local.aws_provider_aliases)
  statement {
    sid = "TerraformPlan"
    effect = "Allow"
    resources = ["*"]
    actions = var.read_access_actions
  }
  statement {
    sid = "TerraformApply"
    effect = "Allow"
    resources = ["*"]
    actions = var.full_access_actions
  }
  statement {
    sid = "SSMParameterStoreSecretAccess"
    effect = "Allow"
    actions = ["kms:Decrypt"]
    resources = ["arn:aws:kms:${data.aws_region.current[each.value].name}:${data.aws_caller_identity.current[each.value].id}:alias/aws/ssm"]
  }
}

resource "aws_iam_policy" "codebuild_terraform" {
  for_each = toset(local.aws_provider_aliases)
  name        = "airflow-ec2-policy"
  path        = "/"
  description = "Gives CodeBuild project access to resources within the same aws environment account"

  policy = data.aws_iam_policy_document.codebuild_terraform[each.value].json
} 
