terraform {
  backend "s3" {
    bucket = "private-sparkify"
    key    = "usr-olap/CI_CD/tf-state/terraform.tfstate"
    region = "us-west-2"
  }
}
