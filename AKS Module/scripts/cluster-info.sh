#!/bin/bash
# AKS Cluster Information Script
# This script displays information about the deployed AKS cluster

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
echo -e "${GREEN}AKS Cluster Information${NC}"
echo -e "${GREEN}========================================${NC}"

cd "$ENVIRONMENT_DIR" || exit 1

# Get Terraform outputs
echo -e "${BLUE}Cluster Details:${NC}"
echo "Cluster Name: $(terraform output -raw cluster_name 2>/dev/null || echo 'N/A')"
echo "Cluster ID: $(terraform output -raw cluster_id 2>/dev/null || echo 'N/A')"
echo "Cluster FQDN: $(terraform output -raw cluster_fqdn 2>/dev/null || echo 'N/A')"
echo "Resource Group: $(terraform output -raw resource_group_name 2>/dev/null || echo 'N/A')"
echo "Location: $(terraform output -raw resource_group_location 2>/dev/null || echo 'N/A')"
echo ""

echo -e "${BLUE}Network Details:${NC}"
echo "VNet ID: $(terraform output -raw vnet_id 2>/dev/null || echo 'N/A')"
echo "Subnet ID: $(terraform output -raw subnet_id 2>/dev/null || echo 'N/A')"
echo ""

echo -e "${BLUE}Monitoring:${NC}"
echo "Log Analytics Workspace: $(terraform output -raw log_analytics_workspace_name 2>/dev/null || echo 'N/A')"
echo ""

ACR_LOGIN=$(terraform output -raw acr_login_server 2>/dev/null)
if [ -n "$ACR_LOGIN" ] && [ "$ACR_LOGIN" != "N/A" ]; then
    echo -e "${BLUE}Container Registry:${NC}"
    echo "ACR Login Server: $ACR_LOGIN"
    echo ""
fi

# Get cluster credentials and display kubectl info
CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null)
RESOURCE_GROUP=$(terraform output -raw resource_group_name 2>/dev/null)

if [ -n "$CLUSTER_NAME" ] && [ -n "$RESOURCE_GROUP" ]; then
    echo -e "${BLUE}Getting cluster credentials...${NC}"
    az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" --overwrite-existing &>/dev/null
    
    echo -e "${BLUE}Cluster Status:${NC}"
    kubectl cluster-info
    echo ""
    
    echo -e "${BLUE}Node Status:${NC}"
    kubectl get nodes -o wide
    echo ""
    
    echo -e "${BLUE}Node Pools:${NC}"
    az aks nodepool list --resource-group "$RESOURCE_GROUP" --cluster-name "$CLUSTER_NAME" -o table
    echo ""
    
    echo -e "${BLUE}Namespaces:${NC}"
    kubectl get namespaces
    echo ""
    
    echo -e "${BLUE}System Pods:${NC}"
    kubectl get pods -n kube-system
fi

echo -e "${GREEN}========================================${NC}"
