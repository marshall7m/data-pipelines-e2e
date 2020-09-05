# variable "vpc_id" {
#     type = string
# }

# variable "subnet_ids"{
#     type = list
# }
# variable "postgres_password" {}

# variable "host_volumes_path" {}

variable "service" {
    default = "data_pipeline"
}

variable "s3_buckets_dict" {}
variable "athena_queries_dict" {}
variable "athena_workgroups_dict" {}
variable "glue_jobs_dict" {}
variable "glue_crawlers_dict" {}