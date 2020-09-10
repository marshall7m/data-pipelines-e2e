terraform {
  backend "s3" {
    bucket = "private-sparkify"
    key    = "usr_olap/CI/dev/tf_state/terraform.tfstate"
    region = "us-west-2"
  }
}
