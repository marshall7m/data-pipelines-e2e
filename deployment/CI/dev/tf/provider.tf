provider "aws" {
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY_ID
  region = "us-west-2"
  version = "~> 3.4"
}