# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    key    = "deployment/dev/networking/tf-state/terraform.tfstate"
    region = "us-west-2"
    bucket = "private-demo-org"
  }
}
