# Terraform-Pro

A comprehensive Terraform project repository containing reusable modules and configurations for AWS infrastructure provisioning.

## Project Structure

```
Terraform-Pro/
├── EC2 Module/          # Modular EC2 setup with autoscaling and load balancer
├── Ec2/                 # Standalone EC2 configuration
├── modules/vpc/         # Reusable VPC module
└── S3 and VPC/          # S3 bucket and VPC configurations
```

## Features

- **EC2 Module**: Production-ready EC2 module with:
  - Auto Scaling Group (ASG)
  - Application Load Balancer (ALB)
  - Automated SSH key generation
  - Target tracking scaling policies
  - Multi-environment support (dev/prod)

- **VPC Module**: Reusable VPC infrastructure
- **S3 Configurations**: S3 bucket setup with static website hosting
- **Backend Configuration**: Remote state management with S3 and DynamoDB

## Quick Start

### EC2 Module Deployment

```bash
cd "EC2 Module/envs/dev"
terraform init -reconfigure
terraform plan
terraform apply
```

### Prerequisites

- Terraform >= 1.0
- AWS CLI configured
- S3 bucket for remote state
- DynamoDB table for state locking

## Module Usage

### EC2 Module

```hcl
module "ec2" {
  source = "./modules/ec2"
  
  name          = "my-app"
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  subnet_ids    = ["subnet-xxx", "subnet-yyy"]
  vpc_id        = "vpc-xxx"
  user_data     = file("user_data.sh")
}
```

## Outputs

- Load Balancer DNS
- Auto Scaling Group name
- SSH key paths
- Target Group ARN

## License

See LICENSE file for details.