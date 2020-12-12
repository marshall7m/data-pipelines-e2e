include {
  path = find_in_parent_folders()
}

locals {
    org_vars = read_terragrunt_config(find_in_parent_folders("org.hcl"))
    region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
    
    account_ids = local.org_vars.locals.account_ids
    org = local.org_vars.locals.org
    region = local.region_vars.locals.region
}

terraform {
    source = "github.com/marshall7m/tf_modules/terraform-aws-codebuild"
}

inputs = {
    name = "${local.org}-tf-infrastructure-${local.region}"
    environment_variables = [
        {
            name  = "TF_IN_AUTOMATION"
            value = "true"
            type = "PLAINTEXT"
        },
        {
            name  = "TF_INPUT"
            value = "false"
            type = "PLAINTEXT"
        },
        {
            name  = "TERRAGRUNT_VERSION"
            value = "0.25.4"
            type = "PLAINTEXT"
        },
        {
            name  = "TERRAFORM_VERSION"
            value = "0.13.5"
            type = "PLAINTEXT"
        }
    ]

    build_source = {
        type = "CODEPIPELINE"
        buildspec = "deployments/${path_relative_to_include()}/buildspec.yml"
    }

    cross_account_assumable_roles = [
        "arn:aws:iam::${local.account_ids.dev}:role/tf-plan-access-role",
        "arn:aws:iam::${local.account_ids.dev}:role/tf-apply-access-role"
    ]
    
    artifacts = {
        type = "CODEPIPELINE"
    }
}