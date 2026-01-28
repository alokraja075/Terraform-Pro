# Terraform-Pro

**Terraform-Pro** is a comprehensive collection of infrastructure-as-code (IaC) examples and reusable modules for AWS and Azure, designed for real-world cloud automation, DevOps, and interview preparation.

## Repository Overview

This repository includes:

- **Modular Terraform code** for AWS (EC2, VPC, S3, Lambda, EKS) and Azure (VM, AKS)
- **Reusable Ansible roles and playbooks** for application deployment (e.g., Splunk on Windows)
- **Scenario-based interview questions** for all major topics

### Directory Structure

```
Terraform-Pro/
├── AKS Module/         # Azure Kubernetes Service (Terraform)
├── Ansible/            # Ansible automation (roles, playbooks, Splunk deployment)
├── Azure VM Module/    # Azure VM Terraform modules and environments
├── EC2 Module/         # AWS EC2 reusable module (with dev/prod wrappers)
├── Ec2/                # Standalone EC2 example
├── EKS Module/         # AWS EKS (Kubernetes) modules and node groups
├── Initial files/      # Minimal Terraform boilerplate
├── Lambda/             # AWS Lambda samples
├── S3 and VPC/         # S3 static site, VPC, and related AWS samples
└── scenario-interview-questions.md # Scenario-based interview questions
```

## Prerequisites

- Terraform >= 1.0
- AWS CLI and/or Azure CLI configured with credentials
- Remote state (S3/DynamoDB for AWS, Azure Storage for Azure)
- Ansible >= 2.10 (for automation)
- Python 3.7+ with pywinrm (for Windows host management)

## Getting Started

- Configure cloud CLIs:
```bash
# AWS
aws configure

# Azure
az login
az account set --subscription <SUBSCRIPTION_ID>
```

- Optional environment variables:
```bash
export AWS_PROFILE=default
export AWS_REGION=us-east-1
```

## Remote State Configuration

- AWS (S3 + DynamoDB): use provided backend files under env folders (e.g., [EC2 Module/envs/dev/backend.tf](EC2%20Module/envs/dev/backend.tf)). Create the S3 bucket and DynamoDB table first.
```bash
# Example names (adjust to your env)
aws s3 mb s3://my-terraform-state-bucket
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

- Azure (Azure Storage): update backend in env folders (see [Azure VM Module/envs/dev/backend.tf](Azure%20VM%20Module/envs/dev/backend.tf)). Create storage resources first.
```bash
az group create -n terraform-state-rg -l eastus
az storage account create -g terraform-state-rg -n <accountname> -l eastus --sku Standard_LRS
az storage container create --name tfstate --account-name <accountname>
```

## Usage Examples

### EC2 Module (Recommended)

Features:
- Launch Template, Auto Scaling Group, Application Load Balancer
- Security Groups, SSH key management, user data
- Dev/prod wrappers with separate backends and tfvars

**Deploy (dev):**
```bash
cd "EC2 Module/envs/dev"
terraform init -reconfigure
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

**Module usage:**
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

#### Module Variables

Source: [EC2 Module/modules/ec2/variables.tf](EC2%20Module/modules/ec2/variables.tf)

| Variable | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | `"app"` | – |
| `ingress_ports` | `list(number)` | `[22, 80, 8000]` | List of ingress ports |
| `ami` | `string` | `"ami-0c02fb55956c7d316"` | – |
| `instance_type` | `string` | `"t2.micro"` | – |
| `EC2_default_storage_size` | `string` | `"20"` | – |
| `environments` | `string` | `"dev"` | Environment name (e.g., prod, dev) |
| `key_pair_name` | `string` | `"Instance-KP"` | Key pair name |
| `user_data` | `string` | `""` | User data script to initialize the instance |
| `subnet_ids` | `list(string)` | `[...]` | List of subnet IDs |
| `vpc_id` | `string` | `"vpc-..."` | VPC |

### Ansible: Splunk on Windows

Automate Splunk Enterprise deployment to Windows servers:
```bash
cd Ansible
pip install -r requirements.txt
vi inventory/windows_hosts.ini
ansible-vault create group_vars/windows/vault.yml
chmod +x deploy_splunk.sh
./deploy_splunk.sh
# Or:
ansible-playbook playbooks/splunk_windows_install.yml --ask-vault-pass
```

Key features:
- Automated Splunk install, config, firewall, health checks
- Reusable role for multiple deployments
- See [Ansible/README.md](Ansible/README.md) for details

### Other Examples
- **Ec2/**: Standalone EC2 config
- **S3 and VPC/**: Static website, VPC, ALB, manual EC2
- **Initial files/**: Minimal Terraform boilerplate
- **Lambda/**: AWS Lambda samples

### AKS Module (Azure Kubernetes Service)

Quickstart (dev):
```bash
cd "AKS Module/envs/dev"
terraform init -reconfigure
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Module usage (example): see [AKS Module/modules/aks](AKS%20Module/modules/aks) and [AKS Module/modules/aks_node_pool](AKS%20Module/modules/aks_node_pool).

#### Module Variables (Cluster)

Source: [AKS Module/modules/aks/variables.tf](AKS%20Module/modules/aks/variables.tf)

| Variable | Type | Default | Description |
|---|---|---|---|
| `resource_group_name` | `string` | – | Name of the resource group |
| `location` | `string` | `"East US"` | Azure location |
| `cluster_name` | `string` | – | Name of the AKS cluster |
| `dns_prefix` | `string` | – | DNS prefix for the cluster |
| `kubernetes_version` | `string` | `"1.28"` | Kubernetes version |
| `sku_tier` | `string` | `"Standard"` | SKU Tier (Free, Standard, Premium) |
| `default_node_pool_name` | `string` | `"default"` | Default node pool name |
| `default_node_pool_vm_size` | `string` | `"Standard_D2s_v3"` | VM size |
| `default_node_pool_node_count` | `number` | `3` | Node count |
| `default_node_pool_min_count` | `number` | `1` | Min nodes |
| `default_node_pool_max_count` | `number` | `5` | Max nodes |
| `enable_auto_scaling` | `bool` | `true` | Enable autoscaling |
| `default_node_pool_os_disk_size_gb` | `number` | `30` | OS disk size |
| `availability_zones` | `list(string)` | `["1","2","3"]` | Zones |
| `vnet_subnet_id` | `string` | – | Subnet ID |
| `network_plugin` | `string` | `"azure"` | Network plugin |
| `network_policy` | `string` | `"azure"` | Network policy |
| `dns_service_ip` | `string` | `"10.2.0.10"` | DNS service IP |
| `service_cidr` | `string` | `"10.2.0.0/24"` | Service CIDR |
| `load_balancer_sku` | `string` | `"standard"` | LB SKU |
| `enable_azure_ad_integration` | `bool` | `true` | Azure AD RBAC |
| `azure_ad_admin_group_object_ids` | `list(string)` | `[]` | Admin group object IDs |
| `azure_rbac_enabled` | `bool` | `true` | Azure RBAC enabled |
| `enable_log_analytics` | `bool` | `true` | Log Analytics integration |
| `log_analytics_workspace_sku` | `string` | `"PerGB2018"` | LA Workspace SKU |
| `log_retention_in_days` | `number` | `30` | Log retention |
| `enable_microsoft_defender` | `bool` | `false` | Defender for Containers |
| `enable_key_vault_secrets_provider` | `bool` | `false` | KV secrets provider |
| `secret_rotation_enabled` | `bool` | `true` | Secret rotation |
| `secret_rotation_interval` | `string` | `"2m"` | Rotation interval |
| `enable_http_application_routing` | `bool` | `false` | HTTP app routing |
| `enable_private_cluster` | `bool` | `false` | Private cluster |
| `create_acr` | `bool` | `false` | Create ACR |
| `acr_name` | `string` | `""` | ACR name |
| `acr_sku` | `string` | `"Standard"` | ACR SKU |
| `acr_admin_enabled` | `bool` | `false` | ACR admin enabled |
| `tags` | `map(string)` | `{}` | Tags |

#### Module Variables (Node Pool)

Source: [AKS Module/modules/aks_node_pool/variables.tf](AKS%20Module/modules/aks_node_pool/variables.tf)

| Variable | Type | Default | Description |
|---|---|---|---|
| `node_pool_name` | `string` | – | Node pool name |
| `cluster_id` | `string` | – | AKS cluster ID |
| `vm_size` | `string` | `"Standard_D2s_v3"` | VM size |
| `node_count` | `number` | `3` | Node count |
| `min_count` | `number` | `1` | Min nodes |
| `max_count` | `number` | `5` | Max nodes |
| `enable_auto_scaling` | `bool` | `true` | Enable autoscaling |
| `os_disk_size_gb` | `number` | `30` | OS disk size |
| `os_type` | `string` | `"Linux"` | OS type |
| `mode` | `string` | `"User"` | Pool mode |
| `vnet_subnet_id` | `string` | – | Subnet ID |
| `availability_zones` | `list(string)` | `["1","2","3"]` | Zones |
| `max_pods` | `number` | `30` | Max pods per node |
| `os_disk_type` | `string` | `"Managed"` | Disk type |
| `priority` | `string` | `"Regular"` | Priority (Regular/Spot) |
| `eviction_policy` | `string` | `"Delete"` | Spot eviction policy |
| `spot_max_price` | `number` | `-1` | Spot max price |
| `max_surge` | `string` | `"10%"` | Upgrade surge |
| `node_labels` | `map(string)` | `null` | Node labels |
| `node_taints` | `list(string)` | `[]` | Node taints |
| `tags` | `map(string)` | `{}` | Tags |

### Azure VM Module

Quickstart (dev):
```bash
cd "Azure VM Module/envs/dev"
terraform init -reconfigure
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Module usage (example): see [Azure VM Module/modules/vm](Azure%20VM%20Module/modules/vm). Backend guidance and variables are documented in [Azure VM Module/README.md](Azure%20VM%20Module/README.md).

#### Module Variables

Source: [Azure VM Module/modules/vm/variables.tf](Azure%20VM%20Module/modules/vm/variables.tf)

| Variable | Type | Default | Description |
|---|---|---|---|
| `resource_group_name` | `string` | – | Name of the Azure Resource Group |
| `location` | `string` | `"East US"` | Azure region |
| `vm_name` | `string` | – | Virtual machine name |
| `vm_size` | `string` | `"Standard_B2s"` | VM size |
| `os_type` | `string` | `"Linux"` | OS type (Linux/Windows) |
| `image_publisher` | `string` | `"Canonical"` | Image publisher |
| `image_offer` | `string` | `"0001-com-ubuntu-server-focal"` | Image offer |
| `image_sku` | `string` | `"20_04-lts-gen2"` | Image SKU |
| `image_version` | `string` | `"Latest"` | Image version |
| `admin_username` | `string` | `"azureuser"` | Admin username |
| `admin_password` | `string` | `null` | Admin password (Windows) |
| `ssh_public_key` | `string` | `null` | SSH public key (Linux) |
| `os_disk_caching` | `string` | `"ReadWrite"` | OS disk caching |
| `os_disk_storage_account_type` | `string` | `"Premium_LRS"` | OS disk storage type |
| `subnet_id` | `string` | – | Subnet ID |
| `private_ip_allocation` | `string` | `"Dynamic"` | Private IP allocation |
| `create_public_ip` | `bool` | `true` | Create public IP |
| `security_rules` | `list(object)` | `[...]` | NSG security rules |
| `enable_monitoring` | `bool` | `true` | Enable Log Analytics |
| `log_retention_days` | `number` | `30` | Log retention |
| `tags` | `map(string)` | `{ Environment = "dev", Created_by = "Terraform" }` | Resource tags |

### EKS Module (AWS Kubernetes)

Quickstart (dev):
```bash
cd "EKS Module/envs/dev"
terraform init -reconfigure
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Module usage (example): see [EKS Module/modules/eks](EKS%20Module/modules/eks) and [EKS Module/modules/eks_node_group](EKS%20Module/modules/eks_node_group).

#### Module Variables (Cluster)

Source: [EKS Module/modules/eks/variables.tf](EKS%20Module/modules/eks/variables.tf)

| Variable | Type | Default | Description |
|---|---|---|---|
| `cluster_name` | `string` | – | Name of the EKS cluster |
| `kubernetes_version` | `string` | `"1.29"` | Kubernetes version |
| `subnet_ids` | `list(string)` | – | Subnets for cluster |
| `security_group_ids` | `list(string)` | `[]` | Additional SGs |
| `vpc_id` | `string` | – | VPC ID |
| `enabled_cluster_log_types` | `list(string)` | `[api,audit,authenticator,controllerManager,scheduler]` | Cluster logs |
| `endpoint_private_access` | `bool` | `true` | Private endpoint |
| `endpoint_public_access` | `bool` | `true` | Public endpoint |
| `create_security_group` | `bool` | `true` | Create SG |
| `create_cloudwatch_log_group` | `bool` | `true` | Create CW log group |
| `log_retention_in_days` | `number` | `30` | Log retention |
| `enable_irsa` | `bool` | `true` | IRSA enabled |
| `tags` | `map(string)` | `{}` | Tags |

#### Module Variables (Node Group)

Source: [EKS Module/modules/eks_node_group/variables.tf](EKS%20Module/modules/eks_node_group/variables.tf)

| Variable | Type | Default | Description |
|---|---|---|---|
| `cluster_name` | `string` | – | EKS cluster name |
| `node_group_name` | `string` | – | Node group name |
| `subnet_ids` | `list(string)` | – | Subnets for nodes |
| `vpc_id` | `string` | – | VPC ID |
| `cluster_security_group_ids` | `list(string)` | `[]` | Cluster SGs |
| `kubernetes_version` | `string` | `null` | Node group k8s version |
| `desired_size` | `number` | `2` | Desired nodes |
| `min_size` | `number` | `1` | Min nodes |
| `max_size` | `number` | `5` | Max nodes |
| `instance_types` | `list(string)` | `["t3.medium"]` | Instance types |
| `disk_size` | `number` | `30` | Node disk size |
| `labels` | `map(string)` | `{}` | Node labels |
| `create_security_group` | `bool` | `true` | Create SG |
| `enable_ssm_access` | `bool` | `true` | SSM access |
| `tags` | `map(string)` | `{}` | Tags |

### Lambda Module

This repo includes a placeholder for Lambda examples. See [Lambda/](Lambda) for env scaffolding and [Lambda/scripts/deploy.sh](Lambda/scripts/deploy.sh) for helper usage.

#### Module Variables

Source: [Lambda/modules/lambda/variables.tf](Lambda/modules/lambda/variables.tf)

| Variable | Type | Default | Description |
|---|---|---|---|
| `function_name` | `string` | – | Lambda function name |
| `runtime` | `string` | `"python3.12"` | Runtime |
| `handler` | `string` | `"app.lambda_handler"` | Handler |
| `timeout` | `number` | `10` | Timeout (s) |
| `memory_size` | `number` | `128` | Memory (MB) |
| `environment` | `map(string)` | `{}` | Environment variables |
| `tags` | `map(string)` | `{}` | Resource tags |
| `source_dir` | `string` | – | Absolute path to source dir |
| `build_dir` | `string` | `null` | Build artifacts dir |

### S3 and VPC Examples

See [S3 and VPC/s3 bucket](S3%20and%20VPC/s3%20bucket) and [S3 and VPC/VPC](S3%20and%20VPC/VPC) for bucket and networking samples, plus [S3 and VPC/EC2-Man](S3%20and%20VPC/EC2-Man) for ALB/EC2 manual setup.

## Common Terraform Commands
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

## Troubleshooting

- Provider auth issues: verify `aws configure` or `az login` and environment variables.
- State lock stuck:
```bash
terraform force-unlock <LOCK_ID>
```
- Version mismatches: run `terraform init -upgrade` and check `versions.tf` in each module.
- Formatting/validation:
```bash
terraform fmt -recursive
terraform validate
```

## Contributing

- Branching: work on feature branches (e.g., `feature/Terraform`) and open PRs against `main`.
- Style: keep modules small, composable, and documented. Use remote backends.
- Security: never commit secrets; use Ansible Vault, AWS Secrets Manager, Azure Key Vault.

## Scenario-Based Interview Questions

For advanced technical and scenario-based interview preparation, see [scenario-interview-questions.md](scenario-interview-questions.md):
- 50+ scenario-based questions for each major topic (Terraform, AKS, Azure VM, EC2, EKS, Lambda, S3 & VPC, Ansible)
- Expert-level, real-world, and troubleshooting scenarios
- Sections organized by technology for easy review

## License
See LICENSE for details.
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
## Scenario-Based Interview Questions

For advanced technical and scenario-based interview preparation, see the [scenario-interview-questions.md](scenario-interview-questions.md) file in this repository. It contains:

- 50+ scenario-based questions for each major topic (Terraform, AKS, Azure VM, EC2, EKS, Lambda, S3 & VPC, Ansible)
- Expert-level, real-world, and troubleshooting scenarios
- Sections organized by technology for easy review

Use this resource to prepare for interviews, technical discussions, or to assess your own knowledge across the tools and modules included in this repo.

See LICENSE for details.
