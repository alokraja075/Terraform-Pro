#!/bin/bash
# EKS Cluster Deployment Script
# This script automates the deployment of EKS clusters to AWS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT="${1:-dev}"
ACTION="${2:-apply}"

if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "prod" ]; then
    echo -e "${RED}Error: Environment must be 'dev' or 'prod'${NC}"
    exit 1
fi

if [ "$ACTION" != "apply" ] && [ "$ACTION" != "destroy" ] && [ "$ACTION" != "plan" ]; then
    echo -e "${RED}Error: Action must be 'apply', 'destroy', or 'plan'${NC}"
    exit 1
fi

ENVIRONMENT_DIR="../envs/$ENVIRONMENT"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}EKS Cluster Deployment Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${YELLOW}Environment: $ENVIRONMENT${NC}"
echo -e "${YELLOW}Action: $ACTION${NC}"
echo ""

# Check if environment directory exists
if [ ! -d "$ENVIRONMENT_DIR" ]; then
    echo -e "${RED}Error: Environment directory $ENVIRONMENT_DIR not found${NC}"
    exit 1
fi

# Change to environment directory
cd "$ENVIRONMENT_DIR"

echo -e "${YELLOW}Current directory: $(pwd)${NC}"
echo ""

# Initialize Terraform if .terraform directory doesn't exist
if [ ! -d ".terraform" ]; then
    echo -e "${GREEN}Initializing Terraform...${NC}"
    terraform init
    echo ""
fi

# Validate configuration
echo -e "${GREEN}Validating Terraform configuration...${NC}"
terraform validate
echo ""

# Plan
if [ "$ACTION" = "plan" ] || [ "$ACTION" = "apply" ]; then
    echo -e "${GREEN}Creating Terraform plan...${NC}"
    terraform plan -out=tfplan
    echo ""
fi

# Apply or Destroy
if [ "$ACTION" = "apply" ]; then
    echo -e "${YELLOW}Applying Terraform configuration...${NC}"
    echo -e "${RED}This will create AWS resources and incur costs.${NC}"
    read -p "Do you want to continue? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        terraform apply tfplan
        echo ""
        echo -e "${GREEN}Deployment complete!${NC}"
        echo -e "${GREEN}Cluster information:${NC}"
        terraform output
    else
        echo -e "${YELLOW}Deployment cancelled${NC}"
        rm -f tfplan
    fi
elif [ "$ACTION" = "destroy" ]; then
    echo -e "${RED}WARNING: This will destroy all resources for $ENVIRONMENT environment${NC}"
    read -p "Type 'destroy-$ENVIRONMENT' to confirm: " confirm
    
    if [ "$confirm" = "destroy-$ENVIRONMENT" ]; then
        terraform destroy
        echo ""
        echo -e "${GREEN}Resources destroyed${NC}"
    else
        echo -e "${YELLOW}Destroy cancelled${NC}"
    fi
fi

# Configure kubeconfig
if [ "$ACTION" = "apply" ]; then
    echo ""
    echo -e "${GREEN}Configuring kubeconfig...${NC}"
    CLUSTER_NAME=$(terraform output -raw cluster_id 2>/dev/null || echo "")
    AWS_REGION="${AWS_REGION:-us-east-1}"
    
    if [ -z "$CLUSTER_NAME" ]; then
        echo -e "${YELLOW}Could not retrieve cluster name. Please configure kubeconfig manually:${NC}"
        echo "aws eks update-kubeconfig --region $AWS_REGION --name <cluster-name>"
    else
        aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"
        echo -e "${GREEN}kubeconfig configured successfully${NC}"
        echo -e "${GREEN}You can now use kubectl:${NC}"
        echo "kubectl get nodes"
    fi
fi

echo ""
echo -e "${GREEN}Script completed${NC}"
