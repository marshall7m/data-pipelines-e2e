/* variable "postgres_username" {
    type = string
}
variable "postgres_password" {
    type = string
}
variable "airflow_backend_db" {
    type = string
} */

# variable "ami" {
#   type = string
#   default     = "ami-a042f4d8" # CentOS 7 community image
#   description = "AMI code for the Airflow server"
# }

# variable "instance_type" {
#   type = string
#   description = "Instance type for the Airflow server"
# }

# variable "key" {
#   type = string
#   description = "AWS SSH Key Pair name"
# }

# variable "subnet_ids" {
#   type        = list
#   description = "List of AWS subnet ids for Airflow server and database"
# }

# variable "vpc_id" {
#   type        = string
#   description = "AWS VPC in which to create the Airflow server"
# }

# variable "security_group_id" {
#   type        = string
#   description = "AWS Security group in which to create the Airflow server"
# }

# variable "db_password" {
#   type = string
#   description = "Password for the PostgreSQL instance"
# }

# variable "fernet_key" {
#   type = string
#   description = "Key for encrypting data in the database - see Airflow docs"
# }

# variable "host_volumes_path" {}

# variable "container_volumes_path" {
#   default = "/usr/local/airflow"
# }

# variable "host_dags_path" {
#     default = "%s/src/dags"
# }

# variable "container_dags_path" {
#     default = "/usr/local/airflow/dags"
# }

# variable "host_plugins_path"{
#     default = "%s/src/plugins"
# }
# variable "container_plugins_path" {
#     default = "/usr/local/airflow/plugins"
# }

variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}

variable "load_examples" {
    default = "false"
}
variable "executor" {
    default = "LocalExecutor"
}

variable "AIRFLOW_HOME" {
    default = "opt/airflow"
}

variable "service" {
    default = "data_pipeline"
}

# variable "s3_buckets_dict" {}
# variable "athena_queries_dict" {}
# variable "athena_workgroups_dict" {}
# variable "glue_jobs_dict" {}
# variable "glue_crawlers_dict" {}