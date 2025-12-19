# Terraform-Pro

Infrastructure-as-code examples and reusable modules for AWS, covering EC2, autoscaling, ALB, VPC, and S3.

## Repository Layout

```
Terraform-Pro/
├── EC2 Module/        # Reusable EC2 module + env wrappers (dev/prod)
│   ├── modules/ec2/   # Launch template, ASG, ALB, SG, key handling
│   ├── envs/dev|prod/ # Environment wrappers with backend + tfvars
│   └── scripts/       # deploy.sh helper
├── Ec2/               # Standalone EC2 example (single instance)
├── Initial files/     # Base Terraform scaffolding and versions
├── Lambda/            # Placeholder for Lambda samples
└── S3 and VPC/        # S3 static site + VPC example configs
```

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with credentials and default region
- Remote state (S3 bucket + DynamoDB lock table) when using provided backend files

## EC2 Module (preferred path)

Features (modules/ec2):
- Launch Template with user data and key pair injection
- Auto Scaling Group with instance refresh (rolling) and target tracking
- Application Load Balancer, target group, listener, and ASG attachment
- Security Group with configurable ingress ports
- Optional local SSH key generation

Environments (envs/dev, envs/prod):
- Separate backend.tf per env
- Variables via terraform.tfvars (edit before deploy)
- Helper script: scripts/deploy.sh

Deploy dev:
```bash
cd "EC2 Module/envs/dev"
terraform init -reconfigure
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Deploy prod (same steps under envs/prod).

Use the module directly:
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

## Other Examples

- Ec2/: single-instance Terraform config with its own backend/vars.
- S3 and VPC/: static website bucket plus VPC samples (includes ALB/EC2-manual subdirs and assets).
- Initial files/: minimal Terraform boilerplate.
- Lambda/: placeholder for future Lambda samples.

## Common Commands

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

## Outputs (EC2 module)

- Application Load Balancer DNS name
- Auto Scaling Group name
- SSH key paths (if generated locally)
- Target Group ARN

## Cleanup

Run `terraform destroy` in the env or example directory to tear down resources.

## License

See LICENSE for details.
