locals {
  # aws_provider_aliases = ["aws.dev", "aws.staging", "aws.prod"]
  aws_provider_aliases = ["aws.default"]
}

data "aws_region" "current" {
  for_each = toset(local.aws_provider_aliases)
  provider = aws.default
}

data "aws_caller_identity" "current" {
  for_each = toset(local.aws_provider_aliases)
  provider = aws.default
}

# provider "aws" {
#   profile = "dev"
#   alias = "dev"
# }

# provider "aws" {
#   profile = "staging"
#   alias = "staging"
# }

# provider "aws" {
#   profile = "prod"
#   alias = "prod"
# }

provider "aws" {
  region = "us-west-2"
  alias = "default"
}