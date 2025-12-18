provider "aws" {
  region = var.region
}

module "app_ec2" {
  source        = "../../modules/ec2"
  name          = var.name
  ami           = var.ami
  key_pair_name = var.key_pair_name
  user_data     = file("${path.module}/user_data.sh")
  instance_type = var.instance_type
  subnet_ids    = var.subnet_ids
}

