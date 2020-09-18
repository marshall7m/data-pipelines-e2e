variable "env" {}

variable "vpc_id" {
  type        = string
  default = null
}

variable "private_bucket" {}

variable "resource_prefix" {
    default = ""
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

variable "create_default_instances_sg" {
  default = false
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

variable "rds_dbs_security_groups" {
  default = []
}

variable "create_default_dbs_sg" {
  default = false
}