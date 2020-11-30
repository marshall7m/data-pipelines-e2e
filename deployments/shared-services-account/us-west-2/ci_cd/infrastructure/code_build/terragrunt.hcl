include {
  path = find_in_parent_folders()
}

locals {
    org_vars = read_terragrunt_config(find_in_parent_folders("org.hcl"))
    aws_account_ids = local.org_vars.locals.aws_account_ids
}

terraform {
    source = "github.com/marshall7m/tf_modules/terraform-aws-tf-codebuild"
}

inputs = {
    name = "tf-infrastructure"
    resource_prefix = "demo-org"
    resource_suffix = "us-west-2"
    terraform_version = "0.13.5"
    terragrunt_version = "0.25.4"
    source_type = "CODEPIPELINE"
    cross_account_assumable_roles = [
        "arn:aws:iam::${local.aws_account_ids.dev}:role/tf-plan-access-role",
        "arn:aws:iam::${local.aws_account_ids.dev}:role/tf-apply-access-role"
    ]
    artifacts = {
        type = "CODEPIPELINE"
    }
    buildspec = "deployments/${path_relative_to_include()}/buildspec.yml"
    
}