variable "env" {}

variable "resource_prefix" {
    default = ""
}

variable "vpc_id" {
  type        = string
  default = null
}

variable "private_bucket" {}

variable "private_subnets_cidr_blocks" {
  default = []
}

variable "private_subnets_ids" {
  default = []
}

####CREATE AIRFLOW DEFAULT RESOURCES####

variable "create_airflow_instance" {
  default = false
}

variable "create_airflow_instance_sg" {
  default = false
}

variable "airflow_instance_ssm_access" {
  default = false
}

variable "create_airflow_db" {
  default = false
}

variable "create_airflow_db_sg" {
  default = false
}

####AIRFLOW DEFAULT RESOURCES PARAMETERS####

variable "airflow_instance_ami" {
  default = null
}

variable "airflow_instance_type" {
  default = null
}

variable "airflow_instance_ssh_cidr_blocks" {
  default = []
}

variable "airflow_instance_subnet_id" {
  default = null
}

variable "airflow_instance_key_name" {
  default = null
}

variable "airflow_db_instance_class" {
  default = null
}

variable "airflow_db_allocated_storage" {
  default = 5
}

variable "airflow_db_name" {
  default = null
}

variable "airflow_db_username" {
  default = null
}

variable "airflow_db_password" {
  default = null
}

variable "airflow_instance_tags" {
  default = {}
}

variable "airflow_instance_user_data" {
  default = ""
}

####ADDITIONAL USER DEFINED AWS RESOURCES####

variable "glue_role_arn" {
  default = null
}

variable "glue_jobs" {
  default = []
}

variable "glue_crawlers" {
  default = []
}

variable "athena_databases" {
  default = []
}

variable "athena_workgroups" {
  default = []
}

variable "athena_queries" {
  default = []
}

variable "ec2_instances" {
  default = []
}

variable "ec2_instances_security_groups" {
  default = []
}

variable "rds_dbs" {
  default = []
}

variable "rds_dbs_subnet_group" {
  default = []
}

variable "rds_dbs_security_groups" {
  default = []
}