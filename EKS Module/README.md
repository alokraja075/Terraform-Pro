# EKS Terraform Module

This Terraform module creates a production-ready Amazon EKS (Elastic Kubernetes Service) cluster with managed node groups.

## Features

- **EKS Cluster Management**: Fully managed Kubernetes cluster with configurable logging and endpoints
- **Node Groups**: Scalable managed node groups with auto-scaling capabilities
- **IAM Roles & Policies**: Proper IAM setup for cluster and worker nodes
- **IRSA Support**: IAM Roles for Service Accounts (IRSA) enabled for secure pod-to-AWS service communication
- **CloudWatch Logging**: Integrated cluster logging to CloudWatch
- **Security Groups**: Custom security groups for cluster and node communication
- **Multi-Environment**: Separate configurations for dev and prod environments

## Module Structure

```
EKS Module/
├── modules/
│   ├── eks/                    # Main EKS cluster module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── eks_node_group/         # EKS node group module
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
└── scripts/                    # Utility scripts
```

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with necessary permissions
- Existing VPC and subnets
- S3 bucket and DynamoDB table for remote state (optional but recommended)

## Required AWS Permissions

The AWS user/role must have permissions for:
- EKS cluster creation and management
- EC2 instance management
- IAM role and policy creation
- CloudWatch log group creation
- VPC/subnet access

## Usage

### Development Environment

1. Update the variables in `envs/dev/terraform.tfvars`:
   - Replace `vpc_id` with your VPC ID
   - Replace `subnet_ids` with your subnet IDs (minimum 2, recommended 3 across availability zones)

2. Initialize Terraform:
```bash
cd envs/dev
terraform init
```

3. Review the plan:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

### Production Environment

1. Update the variables in `envs/prod/terraform.tfvars`:
   - Replace `vpc_id` with your VPC ID
   - Replace `subnet_ids` with your subnet IDs (minimum 2-3 across availability zones)

2. Initialize Terraform:
```bash
cd envs/prod
terraform init
```

3. Review the plan:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

## Configuring kubeconfig

After cluster creation, configure `kubectl` to access your cluster:

```bash
aws eks update-kubeconfig --region us-east-1 --name eks-dev-cluster
```

Or for production:
```bash
aws eks update-kubeconfig --region us-east-1 --name eks-prod-cluster
```

## Key Module Variables

### EKS Cluster Module

- `cluster_name`: Name of the EKS cluster
- `kubernetes_version`: Kubernetes version (default: 1.29)
- `subnet_ids`: List of subnet IDs for the cluster
- `vpc_id`: VPC ID for the cluster
- `enabled_cluster_log_types`: List of log types to enable
- `endpoint_private_access`: Enable private API endpoint (default: true)
- `endpoint_public_access`: Enable public API endpoint (default: true)
- `enable_irsa`: Enable IAM Roles for Service Accounts (default: true)

### EKS Node Group Module

- `cluster_name`: Name of the EKS cluster
- `node_group_name`: Name of the node group
- `desired_size`: Desired number of nodes (default: 2 for dev, 3 for prod)
- `min_size`: Minimum number of nodes
- `max_size`: Maximum number of nodes
- `instance_types`: EC2 instance types for nodes
- `disk_size`: EBS disk size in GiB
- `labels`: Kubernetes labels for nodes
- `enable_ssm_access`: Enable Systems Manager access

## Outputs

The module provides the following outputs:

- `cluster_id`: EKS cluster ID
- `cluster_endpoint`: EKS API endpoint
- `cluster_arn`: Cluster ARN
- `cluster_version`: Kubernetes version
- `cluster_oidc_issuer_url`: OIDC issuer URL for IRSA
- `oidc_provider_arn`: ARN of the OIDC provider
- `node_group_id`: Node group ID
- `node_group_role_arn`: IAM role ARN for node group
- `cloudwatch_log_group_name`: CloudWatch log group name

## Managing the Cluster

### Scaling Node Groups

Update the `desired_size`, `min_size`, and `max_size` in `terraform.tfvars` and apply:

```bash
terraform apply
```

### Updating Kubernetes Version

Update `kubernetes_version` in `terraform.tfvars` and apply. This updates the cluster first, then node groups:

```bash
terraform apply
```

### Adding Multiple Node Groups

You can add multiple node groups by adding additional module blocks in `main.tf`:

```hcl
module "eks_node_group_compute" {
  source = "../../modules/eks_node_group"

  cluster_name    = module.eks_cluster.cluster_id
  node_group_name = "eks-dev-compute-group"
  # ... other variables
}
```

## IAM and RBAC

The module sets up IRSA (IAM Roles for Service Accounts) by default. This allows Kubernetes service accounts to assume IAM roles for accessing AWS services.

To use IRSA:

1. Create an IAM policy for your service
2. Create a Kubernetes service account
3. Annotate the service account with the IAM role ARN
4. Use the service account in your pod specification

Example:
```bash
eksctl create iamserviceaccount \
  --cluster=eks-dev-cluster \
  --namespace=default \
  --name=my-service-account \
  --attach-policy-arn=arn:aws:iam::ACCOUNT_ID:policy/my-policy
```

## Security Considerations

1. **Network Access**: 
   - Dev environment allows public endpoint access for easier development
   - Prod environment disables public endpoint access (private only)
   
2. **Node Access**:
   - SSM access is enabled by default for secure node management
   - Nodes are placed in private subnets for security

3. **Logging**:
   - Dev: 7-day log retention
   - Prod: 30-day log retention

4. **IAM**:
   - Proper separation of cluster and node group IAM roles
   - Limited permissions following AWS best practices

## Troubleshooting

### Cluster Creation Fails
- Verify VPC and subnets exist and are in the correct region
- Check IAM permissions for EKS cluster creation
- Ensure subnets have proper routing configuration

### Nodes Not Ready
- Check CloudWatch logs in `/aws/eks/cluster-name/cluster`
- Verify node security group allows communication with cluster
- Check node IAM role has proper permissions

### IRSA Not Working
- Verify OIDC provider is created: `aws iam list-open-id-connect-providers`
- Check service account annotations reference correct IAM role

## Cleanup

To destroy all resources:

```bash
cd envs/dev  # or prod
terraform destroy
```

**Warning**: This will delete the EKS cluster and all associated resources. Ensure data is backed up before destroying.

## Best Practices

1. **Use Multiple Availability Zones**: Always deploy subnets across multiple AZs for high availability
2. **Tag Resources**: Use the `common_tags` variable to consistently tag resources
3. **Monitor Logs**: Enable and monitor CloudWatch logs for cluster diagnostics
4. **Use IRSA**: Leverage IRSA instead of node IAM roles for pod credentials
5. **Separate Environments**: Keep dev and prod in separate Terraform states
6. **Remote State**: Use S3 + DynamoDB for remote state management
7. **Version Control**: Track terraform.tfvars in version control with sensitive data redacted

## Support and Documentation

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## License

This module is provided as-is for use with your infrastructure projects.
