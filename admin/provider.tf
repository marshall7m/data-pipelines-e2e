locals {
    aws_provider_aliases = ["aws.dev", "aws.staging", "aws.prod"]
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
}