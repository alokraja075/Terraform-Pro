#!/bin/bash
# Script to view EKS cluster information

ENVIRONMENT="${1:-dev}"
AWS_REGION="${2:-us-east-1}"

if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "prod" ]; then
    echo "Error: Environment must be 'dev' or 'prod'"
    exit 1
fi

cd "../envs/$ENVIRONMENT"

echo "========================================="
echo "EKS Cluster Information - $ENVIRONMENT"
echo "========================================="
echo ""

terraform output

echo ""
echo "To access the cluster:"
echo "aws eks describe-cluster --region $AWS_REGION --name \$(terraform output -raw cluster_id)"
