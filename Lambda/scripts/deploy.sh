#!/usr/bin/env bash
set -euo pipefail

ENV_NAME=${1:-dev}

case "$ENV_NAME" in
  dev|prod) ;;
  *) echo "Usage: $0 [dev|prod]"; exit 1;;
}

WORKDIR="$(dirname "$0")/../envs/${ENV_NAME}"
cd "$WORKDIR"

echo "Initializing Terraform in ${ENV_NAME}..."
terraform init -input=false

echo "Applying Terraform in ${ENV_NAME}..."
terraform apply -auto-approve

echo "Done. Lambda ARN:"
terraform output -json | jq -r '.lambda_arn.value // empty'
