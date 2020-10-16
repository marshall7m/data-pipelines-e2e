terraform {
  backend "s3" {
    bucket = "private-sparkify"
    key    = "usr-olap/data_pipeline/dev/tf-state/terraform.tfstate"
    region = "us-west-2"
  }
  required_providers {
    template = "~> 2.1"
    local    = "~> 1.4"
    null     = "~> 2.1"
  }
}