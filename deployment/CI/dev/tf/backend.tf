terraform {
  backend "s3" {
    bucket = "sparkify-dend-analytics"
    key    = "CI/dev/tf_state/terraform.tfstate"
    region = "us-west-2"
  }
}
