include {
  path = find_in_parent_folders()
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.env_vars.locals.env
}

terraform {
  source = "github.com/marshall7m/tf_modules/terraform-aws-vpc" 
}

inputs = {
  name = "${local.env}-vpc" 
  cidr = "10.0.0.0/16"

  azs = ["us-west-2a", "us-west-2b"]
  
  private_subnets = ["10.0.11.0/28", "10.0.12.0/28"]
  private_dedicated_network_acl = true

  enable_s3_endpoint = true

  enable_ec2messages_endpoint = true
  enable_ec2_endpoint = true
  
  enable_ssm_endpoint = true
  enable_ssmmessages_endpoint = true

  vpc_endpoints_sg_name = "${local.env}-vpc-endpoints"

  enable_nat_gateway = false
  single_nat_gateway = false
  enable_vpn_gateway = false

  create_database_subnet_group = true
  database_subnets = ["10.0.101.0/28", "10.0.102.0/28"]
  create_database_subnet_route_table = false
  create_database_internet_gateway_route = false
  
  
  manage_default_network_acl = false 
  enable_dns_hostnames = true
  enable_dns_support = true
  
  private_inbound_acl_rules	= [
    {
      "description": "Allows inbound https traffic for loading aws package repos in ec2 instances"
      "cidr_block": "0.0.0.0/0",
      "from_port": 443,
      "to_port": 443,
      "protocol": "tcp",
      "rule_action": "allow",
      "rule_number": 101
    },
    { 
      "description": "Allows inbound http traffic for loading aws package repos in ec2 instances"
      "cidr_block": "0.0.0.0/0",
      "from_port": 80,
      "to_port": 80,
      "protocol": "tcp",
      "rule_action": "allow",
      "rule_number": 102
    }
  ]
  
  private_outbound_acl_rules = [
    {
      "description": "Allows outbound https traffic for loading aws package repos in ec2 instances"
      "cidr_block": "0.0.0.0/0",
      "from_port": 443,
      "to_port": 443,
      "protocol": "tcp",
      "rule_action": "allow",
      "rule_number": 101
    },
    { 
      "description": "Allows outbound http traffic for loading aws package repos in ec2 instances"
      "cidr_block": "0.0.0.0/0",
      "from_port": 80,
      "to_port": 80,
      "protocol": "tcp",
      "rule_action": "allow",
      "rule_number": 102
    }
  ]
}