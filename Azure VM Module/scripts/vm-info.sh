#!/bin/bash

# Get Azure VM Information
# This script retrieves information about the deployed Azure VMs

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if environment is specified
if [ -z "$1" ]; then
    print_warning "Usage: $0 <environment>"
    echo "Example: $0 dev"
    exit 1
fi

ENVIRONMENT=$1
ENV_PATH="./envs/${ENVIRONMENT}"

if [ ! -d "$ENV_PATH" ]; then
    print_warning "Environment directory not found: $ENV_PATH"
    exit 1
fi

cd "$ENV_PATH"
print_info "Retrieving VM information for environment: $ENVIRONMENT"

print_info "VM Details:"
terraform output -json | python3 -m json.tool

# Get resource group name
print_info "Getting resource group information..."
RG_NAME=$(terraform output -raw resource_group_name 2>/dev/null || echo "N/A")
if [ "$RG_NAME" != "N/A" ]; then
    print_info "Resource Group: $RG_NAME"
fi
