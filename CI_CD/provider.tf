provider "aws" {
  version = "~> 3.2.0"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
