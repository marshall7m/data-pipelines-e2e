terraform {
  backend "s3" {
    bucket  = "private-demo-org"
    encrypt = true
    key     = "admin/tf-state/terraform.tfstate"
    region  = "us-west-2"
  }
}