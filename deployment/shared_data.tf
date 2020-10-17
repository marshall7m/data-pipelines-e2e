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

data "terraform_remote_state" "airflow_dags" {
  for_each = toset(var.dag_id_list)
  backend  = "s3"
  config = {
    bucket = "private-sparkify"
    key    = "${var.project_id}/data_pipeline/${var.env}/dags/${each.value}/tf-state/terraform.tfstate"
    region = "us-west-2"
  }
}