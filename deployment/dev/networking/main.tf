resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.resource_prefix}-vpc-endpoint-sg"
  description = "Default security group for vpc endpoints"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.32/28", "10.0.0.64/28"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.32/28", "10.0.0.64/28"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.32/28", "10.0.0.64/28"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.32/28", "10.0.0.64/28"]
  }
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.44.0"
  name = "${var.resource_prefix}-vpc" 
  cidr = "10.0.0.0/24"

  azs = ["us-west-2a", "us-west-2b"]
  
  private_subnets = ["10.0.0.32/28", "10.0.0.64/28"]
  private_dedicated_network_acl = true
  private_subnet_suffix = "private"

  enable_s3_endpoint = true

  enable_ec2messages_endpoint = true
  ec2messages_endpoint_security_group_ids = [aws_security_group.vpc_endpoints.id]
  enable_ec2_endpoint = true
  ec2_endpoint_security_group_ids = [aws_security_group.vpc_endpoints.id]
  
  enable_ssm_endpoint = true
  ssm_endpoint_security_group_ids = [aws_security_group.vpc_endpoints.id]
  enable_ssmmessages_endpoint = true
  ssmmessages_endpoint_security_group_ids = [aws_security_group.vpc_endpoints.id]

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
  
  vpc_endpoint_tags = var.tags

  tags = var.tags
}
