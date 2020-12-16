include {
  path = find_in_parent_folders()
}

locals {
  org_vars    = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  org         = local.org_vars.locals.org
  common_tags = local.org_vars.locals.common_tags
  region      = local.region_vars.locals.region
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-s3-bucket"
}

inputs = {
  acl    = "private"
  bucket = "airflow-${local.org}-${local.region}"
  tags   = local.common_tags
}