include {
  path = find_in_parent_folders()
}

dependency "codebuild" {
  config_path = "../codebuild"
}

locals {
  org_vars     = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  org                        = local.org_vars.locals.org
  account_id                 = local.account_vars.locals.account_id
  region                     = local.region_vars.locals.region
  codestar_conn_arn         = local.env_vars.locals.code_star_conn_arn
  github_repo                = local.env_vars.locals.github_repo
  artifact_bucket_name = local.env_vars.locals.bucket

  default_preset_config = {
    source_repo_artifact = 
    validate_command = "terragrunt validate-all --terragrunt-no-auto-init --terragrunt-ignore-external-dependencies && terragrunt hclfmt --terragrunt-check"
    plan_command = "terragrunt plan-all"
    apply_command = "terragrunt apply-all"
  }

  shared_services_preset_config = {
      resource_prefix = "shared-services" 
      target_dir = "shared-services-account/"
  }
}

terraform {
  source = "../../../../../../../tf-modules/terraform-aws-code-pipeline"
}

inputs = {
  account_id                 = local.account_id
  pipeline_name              = "${local.org}-infrastructure-${local.region}"
  artifact_bucket_name = local.artifact_bucket_name
  kms_alias = "${local.org}-infrastructure-${local.region}"
  kms_key_admin_arns         = ["arn:aws:iam::${local.account_id}:role/cross-account-admin-access"]

  stages = [
        {
            name = "source-repo"
            actions = yamldecode(templatefile("source_stage_preset.yaml", {
                resource_prefix = "infrastructure" 
                branch_name = "master" 
                codestar_conn_arn = local.codestar_conn_arn
                repo_id = local.github_repo
            }))
        },
        {
            name = "shared-services"
            actions = yamldecode(templatefile("infrastructure_stage_preset.yaml", merge(local.default_preset_config, local.shared_services_preset_config, {project_name = dependency.codebuild.outputs.build_name})))
        }
    ]
}