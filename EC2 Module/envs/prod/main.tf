provider "aws" {
  region = var.region
}

module "app_ec2" {
  source        = "../../modules/ec2"
  name          = var.name
  ami           = var.ami
  instance_type = var.instance_type
  subnet_ids    = var.subnet_ids
}

output "web_url" {
  value = "http://${module.app_ec2.lb_dns_name}"
}
