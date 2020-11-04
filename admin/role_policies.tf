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

