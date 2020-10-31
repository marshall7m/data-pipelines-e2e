  
output "vpc_id" {
    value = "${module.vpc.vpc_id}"
}

output "private_subnets" {
    value = "${module.vpc.private_subnets}"
}

output "private_subnets_cidr_blocks" {
    value = "${module.vpc.private_subnets_cidr_blocks}"
}

output "private_subnets_arns" {
    value = "${module.vpc.private_subnet_arns}"
}

output "vpc_s3_endpoint_pl_id" {
    value = "${module.vpc.vpc_endpoint_s3_pl_id}"
}
