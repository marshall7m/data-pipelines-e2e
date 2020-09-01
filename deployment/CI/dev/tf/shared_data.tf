data "terraform_remote_state" "networking_dev" {
  backend = "s3"
  config = {
    bucket  = "sparkify-dend-analytics"
    key  = "networking/dev/tf_state/terraform.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "data_pipeline_dev" {
  backend = "s3"
  config = {
    bucket  = "sparkify-dend-analytics"
    key  = "data_pipeline/dev/tf_state/terraform.tfstate"
    region = "us-west-2"
  }
}