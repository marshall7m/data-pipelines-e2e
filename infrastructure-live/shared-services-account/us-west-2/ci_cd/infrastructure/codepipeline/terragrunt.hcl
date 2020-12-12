include {
  path = find_in_parent_folders()
}

locals {
  org_vars       = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_vars       = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars    = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  codebuild_vars = read_terragrunt_config("../codebuild/terragrunt.hcl")

  org                  = local.org_vars.locals.org
  account_id           = local.account_vars.locals.account_id
  region               = local.region_vars.locals.region

  default_stages_config = {
    source_repo_artifact = "source-repo-master"
    validate_command     = "terragrunt validate-all --terragrunt-no-auto-init --terragrunt-ignore-external-dependencies && terragrunt hclfmt --terragrunt-check"
    plan_command         = "terragrunt plan-all"
    apply_command        = "terragrunt apply-all"
    project_name         = local.codebuild_vars.inputs.name
    branch_name          = "master"
    codestar_conn_arn    = local.env_vars.locals.code_star_conn_arn
    repo_id              = local.env_vars.locals.github_repo
  }

  stages = yamldecode(templatefile("stages.yaml", local.default_stages_config))

}

terraform {
  source = "github.com/marshall7m/tf_modules/tf-modules/terraform-aws-code-pipeline"
}

inputs = {
  account_id           = local.account_id
  pipeline_name        = "${local.org}-infrastructure-${local.region}"
  artifact_bucket_name = "${local.org}-infrastructure-${local.region}"
  kms_alias            = "${local.org}-infrastructure-${local.region}"
  kms_key_admin_arns   = ["arn:aws:iam::${local.account_id}:role/cross-account-admin-access"]

  stages = local.stages
}