# Terraform-Pro

Infrastructure-as-code examples and reusable modules for AWS, covering EC2, autoscaling, ALB, VPC, and S3.

## Repository Layout

```
Terraform-Pro/
├── Ansible/           # Ansible automation for application deployment
│   ├── playbooks/     # Ansible playbooks
│   │   └── splunk_windows_install.yml  # Splunk Enterprise Windows installation
│   ├── roles/         # Reusable Ansible roles
│   │   └── splunk_windows/             # Splunk Windows installation role
│   │       ├── tasks/                  # Installation tasks
│   │       ├── vars/                   # Role variables
│   │       └── templates/              # Configuration templates
│   ├── inventory/     # Host inventories
│   │   └── windows_hosts.ini           # Windows hosts configuration
│   ├── group_vars/    # Group-level variables
│   ├── ansible.cfg    # Ansible configuration
│   ├── requirements.txt # Python dependencies
│   └── deploy_splunk.sh # Deployment helper script
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
- Ansible >= 2.10 (for application deployment)
- Python 3.7+ with pywinrm (for Windows host management)

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

- **Ansible/**: Splunk Enterprise deployment automation for Windows servers with reusable roles and playbooks
- Ec2/: single-instance Terraform config with its own backend/vars.
- S3 and VPC/: static website bucket plus VPC samples (includes ALB/EC2-manual subdirs and assets).
- Initial files/: minimal Terraform boilerplate.
- Lambda/: placeholder for future Lambda samples.

## Ansible Deployment (Splunk on Windows)

Deploy Splunk Enterprise to Windows servers using Ansible:

```bash
cd Ansible

# Install requirements
pip install -r requirements.txt

# Configure your Windows hosts
vi inventory/windows_hosts.ini

# Setup credentials with Ansible Vault
ansible-vault create group_vars/windows/vault.yml

# Run deployment
chmod +x deploy_splunk.sh
./deploy_splunk.sh

# Or directly:
ansible-playbook playbooks/splunk_windows_install.yml --ask-vault-pass
```

Key features:
- Automated Splunk Enterprise installation on Windows
- Service configuration and startup verification
- Windows firewall rule automation
- Health check validation
- Reusable role for multiple deployments

See [Ansible/README.md](Ansible/README.md) for detailed configuration and troubleshooting.

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
