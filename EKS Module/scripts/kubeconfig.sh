#!/bin/bash
# Helper script to configure kubeconfig for EKS cluster

ENVIRONMENT="${1:-dev}"
AWS_REGION="${2:-us-east-1}"

if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "prod" ]; then
    echo "Error: Environment must be 'dev' or 'prod'"
    exit 1
fi

# Get cluster name from terraform outputs
cd "../envs/$ENVIRONMENT"

CLUSTER_NAME=$(terraform output -raw cluster_id 2>/dev/null)

if [ -z "$CLUSTER_NAME" ]; then
    echo "Error: Could not retrieve cluster name. Ensure terraform has been applied."
    exit 1
fi

echo "Configuring kubeconfig for cluster: $CLUSTER_NAME in region: $AWS_REGION"

aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"

echo "kubeconfig configured successfully"
echo ""
echo "Test with:"
echo "kubectl get nodes"
echo "kubectl get pods --all-namespaces"
