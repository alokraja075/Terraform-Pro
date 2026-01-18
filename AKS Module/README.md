# AKS Terraform Module

This Terraform module creates a production-ready Azure Kubernetes Service (AKS) cluster with managed node pools, monitoring, and security features.

## Features

- **AKS Cluster Management**: Fully managed Kubernetes cluster with configurable settings
- **Multiple Node Pools**: System and user node pools with auto-scaling capabilities
- **Azure AD Integration**: Role-based access control with Azure Active Directory
- **Network Configuration**: Azure CNI or Kubenet networking with network policies
- **Monitoring & Logging**: Integrated Azure Monitor and Log Analytics
- **Security**: Microsoft Defender for Containers, private cluster option
- **Azure Container Registry**: Optional ACR integration with automatic RBAC assignment
- **Key Vault Integration**: Secrets provider addon for secure secret management
- **Multi-Environment**: Separate configurations for dev and prod environments
- **Spot Instances**: Optional spot node pools for cost optimization (prod)

## Module Structure

```
AKS Module/
├── modules/
│   ├── aks/                    # Main AKS cluster module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── aks_node_pool/          # Additional node pool module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── envs/
│   ├── dev/                    # Development environment
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars
│   └── prod/                   # Production environment
│       ├── backend.tf
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars
├── scripts/
│   ├── deploy.sh               # Deployment automation script
│   ├── cluster-info.sh         # Cluster information script
│   └── kubeconfig.sh           # Kubeconfig setup script
├── README.md
├── LICENSE
└── versions.tf
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.3.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.40.0
- [kubectl](https://kubernetes.io/docs/tasks/tools/) >= 1.27.0
- Azure subscription with appropriate permissions
- Azure Storage Account for Terraform state (optional but recommended)

## Quick Start

### 1. Clone and Navigate

```bash
cd "AKS Module"
```

### 2. Configure Backend (Optional)

Update the backend configuration in `envs/<environment>/backend.tf`:

```hcl
backend "azurerm" {
  resource_group_name  = "terraform-state-rg"
  storage_account_name = "tfstateaksdev"
  container_name       = "tfstate"
  key                  = "aks-dev.tfstate"
}
```

### 3. Configure Variables

Edit `envs/<environment>/terraform.tfvars` or set variables directly:

```hcl
cluster_name       = "aks-dev-cluster"
dns_prefix         = "aks-dev"
kubernetes_version = "1.28"
location           = "East US"

default_node_pool_vm_size = "Standard_D2s_v3"
default_node_pool_min_count = 1
default_node_pool_max_count = 3

create_acr = true
acr_name   = "aksdevacr001"
```

### 4. Deploy Using Script

```bash
cd scripts
./deploy.sh dev apply
```

Or manually:

```bash
cd envs/dev
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 5. Get Cluster Credentials

```bash
cd scripts
./kubeconfig.sh dev
```

Or manually:

```bash
az aks get-credentials --resource-group <resource-group> --name <cluster-name>
kubectl get nodes
```

## Usage Examples

### Basic Development Cluster

```hcl
module "aks_cluster" {
  source = "../../modules/aks"

  resource_group_name = "aks-dev-rg"
  location            = "East US"
  cluster_name        = "aks-dev-cluster"
  dns_prefix          = "aks-dev"
  kubernetes_version  = "1.28"

  default_node_pool_vm_size    = "Standard_D2s_v3"
  default_node_pool_node_count = 2
  enable_auto_scaling          = true
  default_node_pool_min_count  = 1
  default_node_pool_max_count  = 3

  vnet_subnet_id = azurerm_subnet.aks_subnet.id
  
  enable_log_analytics = true
  create_acr          = true
  acr_name            = "aksdevacr001"

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
```

### Production Cluster with Multiple Node Pools

```hcl
module "aks_cluster" {
  source = "../../modules/aks"

  resource_group_name = "aks-prod-rg"
  location            = "East US"
  cluster_name        = "aks-prod-cluster"
  dns_prefix          = "aks-prod"
  kubernetes_version  = "1.28"
  sku_tier            = "Standard"

  default_node_pool_vm_size    = "Standard_D4s_v3"
  default_node_pool_node_count = 3
  enable_auto_scaling          = true
  default_node_pool_min_count  = 3
  default_node_pool_max_count  = 6

  vnet_subnet_id = azurerm_subnet.aks_subnet.id
  
  enable_azure_ad_integration = true
  azure_rbac_enabled         = true
  
  enable_log_analytics      = true
  log_retention_in_days     = 90
  enable_microsoft_defender = true
  
  enable_private_cluster            = true
  enable_key_vault_secrets_provider = true

  create_acr = true
  acr_name   = "aksprodacr001"
  acr_sku    = "Premium"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

module "user_node_pool" {
  source = "../../modules/aks_node_pool"

  node_pool_name = "user"
  cluster_id     = module.aks_cluster.cluster_id
  vm_size        = "Standard_D4s_v3"
  
  enable_auto_scaling = true
  min_count           = 2
  max_count           = 10
  
  vnet_subnet_id = azurerm_subnet.aks_subnet.id
  mode           = "User"
  
  node_labels = {
    "workload-type" = "general"
    "environment"   = "production"
  }
}
```

### Adding a Spot Node Pool

```hcl
module "spot_node_pool" {
  source = "../../modules/aks_node_pool"

  node_pool_name = "spot"
  cluster_id     = module.aks_cluster.cluster_id
  vm_size        = "Standard_D4s_v3"
  
  enable_auto_scaling = true
  min_count           = 0
  max_count           = 10
  
  vnet_subnet_id  = azurerm_subnet.aks_subnet.id
  mode            = "User"
  priority        = "Spot"
  eviction_policy = "Delete"
  spot_max_price  = -1
  
  node_labels = {
    "workload-type" = "batch"
  }
  
  node_taints = [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]
}
```

## Variables

### Core Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| resource_group_name | Name of the resource group | string | - | yes |
| location | Azure location | string | "East US" | no |
| cluster_name | AKS cluster name | string | - | yes |
| dns_prefix | DNS prefix for cluster | string | - | yes |
| kubernetes_version | Kubernetes version | string | "1.28" | no |
| sku_tier | AKS SKU tier | string | "Standard" | no |

### Node Pool Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| default_node_pool_vm_size | VM size for nodes | string | "Standard_D2s_v3" | no |
| default_node_pool_node_count | Initial node count | number | 3 | no |
| enable_auto_scaling | Enable auto-scaling | bool | true | no |
| default_node_pool_min_count | Min nodes for scaling | number | 1 | no |
| default_node_pool_max_count | Max nodes for scaling | number | 5 | no |

### Network Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vnet_subnet_id | Subnet ID for AKS | string | - | yes |
| network_plugin | Network plugin (azure/kubenet) | string | "azure" | no |
| network_policy | Network policy | string | "azure" | no |
| service_cidr | Service CIDR | string | "10.2.0.0/24" | no |

### Security Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| enable_azure_ad_integration | Enable Azure AD RBAC | bool | true | no |
| azure_rbac_enabled | Enable Azure RBAC | bool | true | no |
| enable_private_cluster | Enable private cluster | bool | false | no |
| enable_microsoft_defender | Enable Defender | bool | false | no |

### Monitoring Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| enable_log_analytics | Enable Log Analytics | bool | true | no |
| log_retention_in_days | Log retention period | number | 30 | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | AKS cluster ID |
| cluster_name | AKS cluster name |
| cluster_fqdn | AKS cluster FQDN |
| kube_config | Kubeconfig (sensitive) |
| cluster_identity | Managed identity details |
| kubelet_identity | Kubelet identity details |
| acr_login_server | ACR login server URL |
| log_analytics_workspace_id | Log Analytics workspace ID |

## Deployment Scripts

### deploy.sh

Automated deployment script with validation and confirmation.

```bash
./scripts/deploy.sh <environment> <action>
# environment: dev or prod
# action: plan, apply, or destroy

# Examples:
./scripts/deploy.sh dev plan
./scripts/deploy.sh dev apply
./scripts/deploy.sh prod apply
./scripts/deploy.sh dev destroy
```

### cluster-info.sh

Display cluster information and status.

```bash
./scripts/cluster-info.sh <environment>

# Example:
./scripts/cluster-info.sh dev
```

### kubeconfig.sh

Retrieve and configure kubeconfig.

```bash
./scripts/kubeconfig.sh <environment>

# Example:
./scripts/kubeconfig.sh dev
```

## Best Practices

### Security

1. **Enable Private Cluster**: For production, use `enable_private_cluster = true`
2. **Azure AD Integration**: Always enable for RBAC
3. **Network Policies**: Use Azure Network Policy or Calico
4. **Microsoft Defender**: Enable for production workloads
5. **Key Vault Integration**: Use for sensitive data

### High Availability

1. **Availability Zones**: Deploy across multiple zones
2. **Node Pool Sizing**: Use appropriate VM sizes
3. **Auto-scaling**: Enable with reasonable min/max values
4. **System Node Pool**: Keep separate from user workloads

### Cost Optimization

1. **Spot Instances**: Use for non-critical workloads
2. **Auto-scaling**: Scale down during off-hours
3. **Right-sizing**: Choose appropriate VM sizes
4. **Reserved Instances**: For predictable workloads

### Monitoring

1. **Container Insights**: Enable Log Analytics
2. **Log Retention**: Set appropriate retention periods
3. **Alerts**: Configure monitoring alerts
4. **Metrics**: Track resource utilization

## Network Architecture

### Azure CNI (Recommended)

- Each pod gets an IP from the VNet subnet
- Direct connectivity with VNet resources
- More IPs required but better performance

### Kubenet

- Pods get IPs from internal range
- NAT for external communication
- Fewer VNet IPs required

## Troubleshooting

### Common Issues

1. **Insufficient Subnet Size**
   - Ensure subnet has enough IPs for nodes and pods
   - Use `/24` or larger for Azure CNI

2. **Authentication Failures**
   - Run `az login` to authenticate
   - Check subscription permissions

3. **State Lock Issues**
   - Ensure only one deployment runs at a time
   - Break lock if necessary (with caution)

4. **Node Pool Failures**
   - Check VM quota in the region
   - Verify subnet has available IPs

### Getting Help

```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes

# View cluster logs
az aks show --resource-group <rg> --name <cluster> --query provisioningState

# Check node pool status
az aks nodepool list --resource-group <rg> --cluster-name <cluster> -o table
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Open an issue in the repository
- Check Azure AKS documentation
- Review Terraform Azure Provider docs

## Additional Resources

- [Azure AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/aks)

## Version History

- **1.0.0** - Initial release with full AKS module support
  - Basic cluster creation
  - Multiple node pool support
  - Monitoring and logging
  - Azure AD integration
  - ACR integration
  - Dev and Prod environments
