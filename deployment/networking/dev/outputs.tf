  
output "vpc_id" {
    value = "${module.vpc.vpc_id}"
}

output "private_subnets_ids" {
    value = "${module.vpc.private_subnets}"
}

output "private_subnets_arns" {
    value = "${module.vpc.private_subnet_arns}"
}

output "public_subnets_arns" {
    value = "${module.vpc.public_subnet_arns}"
}
