#!/bin/bash

# Azure VM Deployment Script
# This script initializes, plans, and applies Terraform configuration for Azure VM deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if environment is specified
if [ -z "$1" ]; then
    print_error "Usage: $0 <environment> [destroy]"
    echo "Example: $0 dev"
    echo "Example: $0 prod destroy"
    exit 1
fi

ENVIRONMENT=$1
DESTROY=${2:-""}
ENV_PATH="./envs/${ENVIRONMENT}"

# Validate environment
if [ ! -d "$ENV_PATH" ]; then
    print_error "Environment directory not found: $ENV_PATH"
    exit 1
fi

# Change to environment directory
cd "$ENV_PATH"
print_info "Changed to environment directory: $(pwd)"

# Initialize Terraform
print_info "Initializing Terraform..."
terraform init

# Validate Terraform configuration
print_info "Validating Terraform configuration..."
terraform validate

# Format check
print_info "Checking Terraform format..."
terraform fmt -check -recursive

# Create plan
print_info "Creating Terraform plan..."
PLAN_FILE="tfplan-$(date +%Y%m%d-%H%M%S)"
terraform plan -out="$PLAN_FILE"

# Check if destroy flag is set
if [ "$DESTROY" = "destroy" ]; then
    print_warning "Destroy flag detected. This will destroy all resources."
    read -p "Are you sure you want to destroy? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        print_info "Destroying Terraform resources..."
        terraform destroy -auto-approve
        print_info "Destroy completed successfully"
    else
        print_warning "Destroy cancelled"
    fi
else
    # Apply plan
    read -p "Do you want to apply the plan? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        print_info "Applying Terraform plan..."
        terraform apply "$PLAN_FILE"
        print_info "Infrastructure deployed successfully"
        
        # Display outputs
        print_info "Outputs:"
        terraform output
    else
        print_warning "Apply cancelled"
        rm "$PLAN_FILE"
    fi
fi

print_info "Deployment script completed"
