module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.44.0"
  name = "${local.resource_prefix}-vpc" 
  cidr = "10.0.0.0/24"

  azs = ["us-west-2a", "us-west-2b"]
  
  private_subnets = ["10.0.0.32/28", "10.0.0.64/28"]
  private_dedicated_network_acl = true
  private_subnet_suffix = "private"

  public_subnets = ["10.0.0.96/28", "10.0.0.128/28"]
  public_dedicated_network_acl = true
  public_subnet_suffix = "public"

  enable_s3_endpoint = true

  enable_nat_gateway = false
  single_nat_gateway = false
  enable_vpn_gateway = false

  create_database_subnet_route_table = false
  create_database_internet_gateway_route = false
  create_database_subnet_group = false
   
  manage_default_network_acl = false 
  enable_dns_hostnames = true
  enable_dns_support = true
  
  private_inbound_acl_rules	= [
    {
      "description": "Allows inbound ssh traffic for ec2 instance access"
      "cidr_block": "0.0.0.0/0",
      "from_port": 22,
      "to_port": 22,
      "protocol": "tcp",
      "rule_action": "allow",
      "rule_number": 100
    },
    {
      "description": "Allows inbound https traffic for aws package repos"
      "cidr_block": "0.0.0.0/0",
      "from_port": 443,
      "to_port": 443,
      "protocol": "tcp",
      "rule_action": "allow",
      "rule_number": 101
    },
    { 
      "description": "Allows inbound http traffic for aws package repos"
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
      "description": "Allows outbound ssh traffic for ec2 instance requests"
      "cidr_block": "0.0.0.0/0",
      "from_port": 22,
      "to_port": 22,
      "protocol": "tcp",
      "rule_action": "allow",
      "rule_number": 100
    },
    {
      "description": "Allows outbound https traffic for aws package repos requests"
      "cidr_block": "0.0.0.0/0",
      "from_port": 443,
      "to_port": 443,
      "protocol": "tcp",
      "rule_action": "allow",
      "rule_number": 101
    },
    { 
      "description": "Allows outbound http traffic for aws package repos requests"
      "cidr_block": "0.0.0.0/0",
      "from_port": 80,
      "to_port": 80,
      "protocol": "tcp",
      "rule_action": "allow",
      "rule_number": 102
    }
  ]
  public_inbound_acl_rules = [
    {
      "description": "Allows inbound traffic from ephemeral port ranges for NAT gateway requests"
      "cidr_block": "0.0.0.0/0",
      "from_port": 1024,
      "to_port": 65535,
      "protocol": "tcp",
      "rule_action": "allow",
      "rule_number": 103
    }
  ]
  public_outbound_acl_rules = [
    {
      "description": "Allows outbound traffic from ephemeral port ranges for NAT gateway requests"
      "cidr_block": "0.0.0.0/0",
      "from_port": 1024,
      "to_port": 65535,
      "protocol": "tcp",
      "rule_action": "allow",
      "rule_number": 104
    }
  ]
  
  tags = {
        project_id = "${var.project_id}"
        Environment = "${var.env}"
        Terraform = "true"
        Service = "networking"
        Version = "0.0.1"
  }
}
