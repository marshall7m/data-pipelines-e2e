dependency "networking" {
  config_path = "../../../networking"
  skip_outputs = true
}

inputs = {
  vpc_id = dependency.networking.outputs.vpc_id
  private_subnets = dependency.networking.outputs.private_subnets
  private_subnets_cidr_blocks = dependency.networking.outputs.private_subnets_cidr_blocks
  private_subnets_arns = dependency.networking.outputs.private_subnets_arns
  vpc_s3_endpoint_pl_id = dependency.networking.outputs.vpc_s3_endpoint_pl_id
}

include {
  path = find_in_parent_folders()
}