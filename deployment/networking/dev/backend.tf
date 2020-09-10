
terraform {
  backend "s3" {
    bucket = "sparkify-dend-analytics"
    key    = "usr_olap/networking/dev/tf_state/terraform.tfstate"
    region = "us-west-2"
  }
}