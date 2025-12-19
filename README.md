# Terraform-Pro

Infrastructure-as-code examples and reusable modules for provisioning AWS workloads with Terraform.

## Repository Layout

```
Terraform-Pro/
├── EC2 Module/        # Reusable EC2 + ASG + ALB module with env examples
├── Ec2/               # Standalone EC2 sample configuration
├── Initial files/     # Base Terraform scaffolding
├── Lambda/            # Lambda-related samples (placeholder)
└── S3 and VPC/        # S3 static site and VPC examples
```

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with credentials and region
- Remote state backend (S3 + DynamoDB) if using the provided backend configs

## Getting Started (EC2 Module)

Deploy the dev environment:

```bash
cd "EC2 Module/envs/dev"
terraform init -reconfigure
terraform plan
terraform apply
```

For prod, switch to `EC2 Module/envs/prod` before running the same commands.

## Module Usage Example

```hcl
module "ec2" {
  source        = "./modules/ec2"
  name          = "my-app"
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  subnet_ids    = ["subnet-xxx", "subnet-yyy"]
  vpc_id        = "vpc-xxx"
  user_data     = file("user_data.sh")
}
```

Key capabilities:
- Auto Scaling Group with rolling refresh
- Application Load Balancer + target group and listener
- SSH key generation for the launch template
- Basic security group with configurable ingress ports

## Useful Commands

```bash
terraform fmt         
terraform validate    
terraform plan        
terraform apply       
terraform destroy     
```

## Outputs

- Load Balancer DNS name
- Auto Scaling Group name
- SSH key paths (if generated locally)
- Target Group ARN

## License

See LICENSE for details.
