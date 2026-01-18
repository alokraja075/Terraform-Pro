#!/bin/bash
# Kubeconfig Setup Script
# This script retrieves and configures kubeconfig for the AKS cluster

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ENVIRONMENT="${1:-dev}"

if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "prod" ]; then
    echo -e "${YELLOW}Usage: $0 <environment>${NC}"
    echo "  environment: dev or prod"
    exit 1
fi

ENVIRONMENT_DIR="../envs/$ENVIRONMENT"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}AKS Kubeconfig Setup${NC}"
echo -e "${GREEN}========================================${NC}"

cd "$ENVIRONMENT_DIR" || exit 1

# Get cluster details from Terraform outputs
CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null)
RESOURCE_GROUP=$(terraform output -raw resource_group_name 2>/dev/null)

if [ -z "$CLUSTER_NAME" ] || [ -z "$RESOURCE_GROUP" ]; then
    echo -e "${YELLOW}Error: Could not retrieve cluster information from Terraform outputs${NC}"
    exit 1
fi

echo -e "${BLUE}Cluster Name:${NC} $CLUSTER_NAME"
echo -e "${BLUE}Resource Group:${NC} $RESOURCE_GROUP"
echo ""

# Get credentials
echo -e "${BLUE}Retrieving cluster credentials...${NC}"
az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" --overwrite-existing

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Credentials configured successfully!${NC}"
    echo ""
    echo -e "${BLUE}Testing connection...${NC}"
    kubectl cluster-info
    echo ""
    echo -e "${BLUE}Current context:${NC}"
    kubectl config current-context
    echo ""
    echo -e "${GREEN}You can now use kubectl to manage your cluster${NC}"
else
    echo -e "${YELLOW}Failed to retrieve credentials${NC}"
    exit 1
fi

echo -e "${GREEN}========================================${NC}"
