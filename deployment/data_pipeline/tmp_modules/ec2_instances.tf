resource "aws_instance" "airflow_instance" {
  for_each = {for instance in var.ec2_instances: instance.tags.Name => instance}
  associate_public_ip_address = lookup(each.value, "associate_public_ip_address", false)
  iam_instance_profile = each.value.iam_instance_profile
  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = [
    for name in each.value.vpc_security_groups_names:
    aws_security_group.ec2_instances[name].id
  ]

  key_name = lookup(each.value, "key_name", null)
  root_block_device {
    volume_size = 32
  }

  user_data = lookup(each.value, "user_data", null)

  tags = each.value.tags
}
 
resource "aws_security_group" "ec2_instances" {
  for_each = {for group in var.ec2_instances_security_groups: group.name => group}
  name        = each.key
  description = lookup(each.value, "description", null)
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = {for rule in each.value.ingress: "_" => rule}
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  
  dynamic "egress" {
    for_each = {for rule in each.value.egress: "_" => rule}
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}