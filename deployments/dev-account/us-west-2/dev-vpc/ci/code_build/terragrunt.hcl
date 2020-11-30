locals {
    env_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
    org_vars = read_terragrunt_config(find_in_parent_folders("org.hcl"))
}

terraform {
    source = "github.com/marshall7m/tf_modules/terraform-aws-codebuild"
}

dependency "account_ci_roles" {
    config_path = "../../../../global/iam_roles"
}


inputs = {
    trigger_branch = "master"
    resource_prefix = local.org_vars.locals.org
    resource_suffix = local.account_vars.locals.account_name
    terraform_version = "0.13.5"
    terragrunt_version = "0.25.4"
    target_paths = ["deployments/dev-account"]
    source_type = "CODEPIPELINE"
    builds = [
        {
            name = "validate"
            commands = ["terragrunt init -backend=false", "terragrunt validate-all"]
            service_role_arn = dependency.account_ci_roles.outputs.tf_plan_role_arn
            artifacts = {
                type = "CODEPIPELINE"
            }
        },
        {
            name = "plan"
            commands = ["terragrunt plan-all"]
            service_role_arn = dependency.account_ci_roles.outputs.tf_plan_role_arn
            artifacts = {
                type = "CODEPIPELINE"
            }
        },
        {
            name = "apply"
            commands = ["terragrunt apply-all"]
            service_role_arn = dependency.account_ci_roles.outputs.tf_apply_role_arn
            artifacts = {
                type = "CODEPIPELINE"
            }
        }
    ]
}