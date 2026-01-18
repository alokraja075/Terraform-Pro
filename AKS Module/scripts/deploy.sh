#!/bin/bash
# AKS Cluster Deployment Script
# This script automates the deployment of AKS clusters to Azure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT="${1:-dev}"
ACTION="${2:-apply}"

if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "prod" ]; then
    echo -e "${RED}Error: Environment must be 'dev' or 'prod'${NC}"
    echo "Usage: $0 <environment> <action>"
    echo "  environment: dev or prod"
    echo "  action: plan, apply, or destroy"
    exit 1
fi

if [ "$ACTION" != "apply" ] && [ "$ACTION" != "destroy" ] && [ "$ACTION" != "plan" ]; then
    echo -e "${RED}Error: Action must be 'apply', 'destroy', or 'plan'${NC}"
    exit 1
fi

ENVIRONMENT_DIR="../envs/$ENVIRONMENT"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}AKS Cluster Deployment Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${BLUE}Environment:${NC} $ENVIRONMENT"
echo -e "${BLUE}Action:${NC} $ACTION"
echo -e "${GREEN}========================================${NC}"

# Navigate to environment directory
cd "$ENVIRONMENT_DIR" || exit 1

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}Azure CLI is not installed. Please install it first.${NC}"
    echo "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in to Azure
echo -e "${BLUE}Checking Azure authentication...${NC}"
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}Not logged in to Azure. Please login...${NC}"
    az login
fi

# Display current Azure subscription
SUBSCRIPTION=$(az account show --query name -o tsv)
echo -e "${BLUE}Current Azure Subscription:${NC} $SUBSCRIPTION"

# Terraform initialization
echo -e "${BLUE}Initializing Terraform...${NC}"
terraform init -upgrade

# Terraform validation
echo -e "${BLUE}Validating Terraform configuration...${NC}"
terraform validate

if [ $? -ne 0 ]; then
    echo -e "${RED}Terraform validation failed!${NC}"
    exit 1
fi

# Terraform format check
echo -e "${BLUE}Formatting Terraform files...${NC}"
terraform fmt -recursive

# Execute Terraform action
case $ACTION in
    plan)
        echo -e "${BLUE}Planning Terraform changes...${NC}"
        terraform plan -out=tfplan
        ;;
    apply)
        echo -e "${BLUE}Planning Terraform changes...${NC}"
        terraform plan -out=tfplan
        
        echo -e "${YELLOW}Do you want to proceed with the apply? (yes/no)${NC}"
        read -r CONFIRM
        
        if [ "$CONFIRM" == "yes" ]; then
            echo -e "${BLUE}Applying Terraform changes...${NC}"
            terraform apply tfplan
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}========================================${NC}"
                echo -e "${GREEN}Deployment completed successfully!${NC}"
                echo -e "${GREEN}========================================${NC}"
                
                # Get cluster credentials
                CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null)
                RESOURCE_GROUP=$(terraform output -raw resource_group_name 2>/dev/null)
                
                if [ -n "$CLUSTER_NAME" ] && [ -n "$RESOURCE_GROUP" ]; then
                    echo -e "${BLUE}Getting AKS credentials...${NC}"
                    az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" --overwrite-existing
                    
                    echo -e "${GREEN}Credentials configured successfully!${NC}"
                    echo -e "${BLUE}You can now use kubectl to interact with your cluster.${NC}"
                    echo ""
                    echo -e "${BLUE}Quick commands:${NC}"
                    echo "  kubectl get nodes"
                    echo "  kubectl get pods --all-namespaces"
                    echo "  kubectl cluster-info"
                fi
            else
                echo -e "${RED}Deployment failed!${NC}"
                exit 1
            fi
        else
            echo -e "${YELLOW}Apply cancelled.${NC}"
        fi
        ;;
    destroy)
        echo -e "${RED}WARNING: This will destroy all resources in the $ENVIRONMENT environment!${NC}"
        echo -e "${YELLOW}Type 'destroy-$ENVIRONMENT' to confirm:${NC}"
        read -r CONFIRM
        
        if [ "$CONFIRM" == "destroy-$ENVIRONMENT" ]; then
            echo -e "${BLUE}Destroying Terraform resources...${NC}"
            terraform destroy -auto-approve
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Resources destroyed successfully!${NC}"
            else
                echo -e "${RED}Destroy failed!${NC}"
                exit 1
            fi
        else
            echo -e "${YELLOW}Destroy cancelled.${NC}"
        fi
        ;;
esac

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Script execution completed!${NC}"
echo -e "${GREEN}========================================${NC}"
