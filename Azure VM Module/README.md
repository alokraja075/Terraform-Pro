# Azure VM Module

This module provides a comprehensive Terraform solution for deploying and managing Azure Virtual Machines with networking, security, and monitoring capabilities.

## Features

- **Multi-OS Support**: Deploy both Linux and Windows virtual machines
- **Networking**: Built-in virtual network interface configuration
- **Security**: Network Security Group with customizable security rules
- **Public IP**: Optional public IP address assignment
- **Monitoring**: Optional Log Analytics workspace integration
- **SSH/Password Authentication**: Support for SSH keys (Linux) and passwords (Windows)
- **Storage Options**: Configurable OS disk storage types
- **Environment Management**: Separate dev and prod configurations

## Module Structure

```
Azure VM Module/
├── modules/
│   └── vm/
│       ├── main.tf          # Core VM resources
│       ├── variables.tf      # Input variables
│       ├── outputs.tf        # Output values
│       └── README.md
├── envs/
│   ├── dev/
│   │   ├── backend.tf       # Remote state configuration
│   │   ├── main.tf          # Environment-specific main config
│   │   ├── variables.tf      # Environment variables
│   │   └── outputs.tf        # Environment outputs
│   └── prod/
│       ├── backend.tf
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── scripts/
│   ├── deploy.sh            # Main deployment script
│   └── vm-info.sh           # VM information retrieval script
├── versions.tf              # Provider versions
└── README.md
```

## Prerequisites

- Terraform >= 1.0
- Azure CLI configured with appropriate credentials
- Azure subscription with proper permissions
- Existing VPC/Virtual Network and subnet

## Quick Start

### 1. Deploy to Development Environment

```bash
cd Azure\ VM\ Module/
chmod +x scripts/deploy.sh scripts/vm-info.sh
./scripts/deploy.sh dev
```

### 2. Deploy to Production Environment

```bash
./scripts/deploy.sh prod
```

### 3. Destroy Resources

```bash
./scripts/deploy.sh dev destroy
./scripts/deploy.sh prod destroy
```

### 4. Get VM Information

```bash
./scripts/vm-info.sh dev
./scripts/vm-info.sh prod
```

## Configuration

### Development Environment (`envs/dev/terraform.tfvars`)

```hcl
resource_group_name  = "dev-vm-rg"
location             = "East US"
vm_name              = "dev-vm"
vm_size              = "Standard_B2s"
subnet_id            = "path-to-your-subnet"
create_public_ip     = true
enable_monitoring    = true
```

### Production Environment (`envs/prod/terraform.tfvars`)

```hcl
resource_group_name  = "prod-vm-rg"
location             = "East US"
vm_name              = "prod-vm"
vm_size              = "Standard_D2s_v3"
subnet_id            = "path-to-your-subnet"
create_public_ip     = false
private_ip_allocation = "Static"
enable_monitoring    = true
log_retention_days   = 90
```

## Variables

### Required Variables

| Name | Type | Description |
|------|------|-------------|
| `subnet_id` | `string` | The ID of the subnet where the VM will be placed |

### Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `resource_group_name` | `string` | `dev-vm-rg` | Azure Resource Group name |
| `location` | `string` | `East US` | Azure region |
| `vm_name` | `string` | `dev-vm` | Virtual machine name |
| `vm_size` | `string` | `Standard_B2s` | VM size/SKU |
| `os_type` | `string` | `Linux` | Operating system type (Linux or Windows) |
| `image_publisher` | `string` | `Canonical` | VM image publisher |
| `image_offer` | `string` | `0001-com-ubuntu-server-focal` | VM image offer |
| `image_sku` | `string` | `20_04-lts-gen2` | VM image SKU |
| `image_version` | `string` | `Latest` | VM image version |
| `admin_username` | `string` | `azureuser` | Admin username |
| `admin_password` | `string` | `null` | Admin password (Windows only) |
| `ssh_public_key` | `string` | `null` | Path to SSH public key (Linux only) |
| `create_public_ip` | `bool` | `true` | Create public IP address |
| `private_ip_allocation` | `string` | `Dynamic` | Private IP allocation method |
| `enable_monitoring` | `bool` | `true` | Enable Log Analytics monitoring |
| `log_retention_days` | `number` | `30` | Log retention period in days |
| `tags` | `map(string)` | See defaults | Resource tags |

## Outputs

| Name | Description |
|------|-------------|
| `vm_id` | The ID of the created virtual machine |
| `vm_name` | The name of the virtual machine |
| `private_ip_address` | Private IP address of the VM |
| `public_ip_address` | Public IP address (if created) |
| `resource_group_name` | The resource group name |
| `network_interface_id` | The network interface ID |

## Security Rules (Default)

The module includes default security rules:

- **SSH**: Port 22 (Inbound)
- **RDP**: Port 3389 (Inbound)
- **HTTP**: Port 80 (Inbound)
- **HTTPS**: Port 443 (Inbound)

Customize security rules by passing the `security_rules` variable.

## Examples

### Deploy a Linux VM

```hcl
module "azure_vm" {
  source = "../../modules/vm"

  resource_group_name = "my-rg"
  location            = "East US"
  vm_name             = "my-linux-vm"
  os_type             = "Linux"
  vm_size             = "Standard_B2s"
  subnet_id           = "/subscriptions/.../subnets/my-subnet"
  
  admin_username = "azureuser"
  ssh_public_key = "~/.ssh/id_rsa.pub"
  
  enable_monitoring = true
  
  tags = {
    Environment = "dev"
    Project     = "MyProject"
  }
}
```

### Deploy a Windows VM

```hcl
module "azure_vm" {
  source = "../../modules/vm"

  resource_group_name = "my-rg"
  location            = "East US"
  vm_name             = "my-windows-vm"
  os_type             = "Windows"
  vm_size             = "Standard_D2s_v3"
  subnet_id           = "/subscriptions/.../subnets/my-subnet"
  
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "2022-Datacenter"
  image_version   = "Latest"
  
  admin_username = "adminuser"
  admin_password = var.windows_admin_password
  
  enable_monitoring = true
}
```

## Backend Configuration

The module uses Azure Storage for Terraform state management. Update `backend.tf` with your storage account details:

```hcl
backend "azurerm" {
  resource_group_name  = "terraform-state-rg"
  storage_account_name = "terraformstatesa"
  container_name       = "tfstate"
  key                  = "azure-vm-dev.tfstate"
}
```

## Troubleshooting

### Authentication Issues

Ensure you're authenticated with Azure CLI:
```bash
az login
az account set --subscription <your-subscription-id>
```

### State Lock Issues

If Terraform state is locked:
```bash
cd envs/dev
terraform force-unlock <LOCK_ID>
```

### Network Issues

Verify that the subnet exists and is accessible:
```bash
az network vnet subnet show --resource-group <RG> --vnet-name <VNET> --name <SUBNET>
```

## Cost Optimization

- Use smaller VM sizes (B-series) for development
- Disable public IPs for production workloads
- Adjust log retention periods based on requirements
- Use spot instances for non-production workloads

## Maintenance

### Update Terraform

```bash
terraform version
terraform -upgrade
```

### Apply Updates to Existing Resources

```bash
./scripts/deploy.sh dev
```

### View Resource State

```bash
cd envs/dev
terraform state list
terraform state show <resource_name>
```

## Support and Contributing

For issues or improvements, please create an issue or submit a pull request.

## License

This module is licensed under the MIT License - see the LICENSE file for details.
