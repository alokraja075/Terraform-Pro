provider "aws" {
	region = "us-east-1"
}

module "vpc" {
	source = "../../modules/vpc"

	name      = "terraform-pro-vpc"
	vpc_cidr  = "10.0.0.0/16"
	nat_gateway_strategy = "none" # options: "none" | "single" | "per_az"

	# Example: enable flow logs to an existing CloudWatch Log Group or S3 bucket
	create_flow_logs = false
	flow_logs_destination_type = "cloud-watch-logs" # or "s3"
	flow_logs_destination_arn  = "" # set to the destination ARN if creating flow logs

	enable_s3_endpoint = false
	enable_dynamodb_endpoint = false

	enable_network_acl = false

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
