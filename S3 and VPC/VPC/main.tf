provider "aws" {
	region = "us-east-1"
}

module "vpc" {
	source = "../../modules/vpc"

	name      = "terraform-pro-vpc"
	vpc_cidr  = "10.0.0.0/16"
	enable_nat = false

	tags = {
		Project = "Terraform-Pro"
	}
}

output "vpc_id" {
	value = module.vpc.vpc_id
}

output "public_subnets" {
	value = module.vpc.public_subnet_ids
}

output "private_subnets" {
	value = module.vpc.private_subnet_ids
}
