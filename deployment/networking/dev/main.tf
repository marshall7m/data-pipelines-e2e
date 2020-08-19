provider "aws" {
  profile = "default"
  region  = "us-west-2"
}
  
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.44.0"
  name = "dev-vpc" 
  cidr = "10.0.0.0/24"

  azs = ["us-west-2a", "us-west-2b"]
  
  private_subnets = ["10.0.0.32/28", "10.0.0.64/28"]
  public_subnets  = ["10.0.0.80/28", "10.0.0.96/28"]
  
  public_subnet_suffix = "public"
  private_subnet_suffix = "private"

  #nat gateway
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false
  reuse_nat_ips = false

  enable_vpn_gateway = false

  create_database_subnet_route_table = false
  create_database_internet_gateway_route = false
  create_database_subnet_group = false

  public_dedicated_network_acl = true
   
  manage_default_network_acl = true 
  enable_dns_hostnames = false
  enable_dns_support = false
  
  private_inbound_acl_rules	= [
    {
      "cidr_block": "0.0.0.0/0",
      "from_port": 0,
      "protocol": "-1",
      "rule_action": "deny",
      "rule_number": 100,
      "to_port": 0
    }
  ]
  private_outbound_acl_rules = [
    {
      "cidr_block": "0.0.0.0/0",
      "from_port": 0,
      "protocol": "-1",
      "rule_action": "allow",
      "rule_number": 100,
      "to_port": 0
    }
  ]

  
  
  public_inbound_acl_rules = [
    {
      "cidr_block": "0.0.0.0/0",
      "from_port": 0,
      "protocol": "-1",
      "rule_action": "allow",
      "rule_number": 100,
      "to_port": 0
    }
  ]

  public_outbound_acl_rules	= [
    {
      "cidr_block": "0.0.0.0/0",
      "from_port": 0,
      "protocol": "-1",
      "rule_action": "allow",
      "rule_number": 100,
      "to_port": 0
    }
  ]
  
  
  tags = {
        Environment = "dev"
        Terraform = "true"
        Service = "networking"
        Version = "0.0.1"
  }
}
