terraform {
  backend "s3" {
    bucket = "sparkify-dend-analytics"
    key    = "usr-olap/data_pipeline/dev/tf-state/terraform.tfstate"
    region = "us-west-2"
  }
}