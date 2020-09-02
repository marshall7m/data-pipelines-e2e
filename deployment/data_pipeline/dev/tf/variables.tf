# variable "vpc_id" {
#     type = string
# }

# variable "subnet_ids"{
#     type = list
# }
# variable "aws_access_key" {}
# variable "aws_secret_key" {}

# variable "postgres_password" {}

# variable "host_volumes_path" {}
variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY_ID" {}

variable "service" {
    default = "data_pipeline"
}

variable "s3_buckets_dict" {}
variable "athena_queries_dict" {}
variable "athena_workgroups_dict" {}
variable "glue_jobs_dict" {}
variable "glue_crawlers_dict" {}