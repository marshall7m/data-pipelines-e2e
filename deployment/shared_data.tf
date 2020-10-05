data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "private-sparkify"
    key    = "${var.project_id}/networking/${var.env}/tf-state/terraform.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "CI_CD" {
  backend = "s3"
  config = {
    bucket = "private-sparkify"
    key    = "${var.project_id}/CI_CD/tf-state/terraform.tfstate"
    region = "us-west-2"
  }
}
