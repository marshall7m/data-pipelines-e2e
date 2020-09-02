variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY_ID" {}

variable "github_repo" {
    default = "sparkify_end_to_end"
}

variable "github_owner" {
    default = "marshall7m"
}

variable "github_repo_url" {
    default = "https://github.com/marshall7m/sparkify_end_to_end.git"
}

variable "github_token" {}

variable "base_bucket" {
    default = "sparkify-dend-analytics"
}

