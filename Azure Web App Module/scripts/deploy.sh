#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/deploy.sh [envs/dev|envs/prod]
ENV_DIR=${1:-envs/dev}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULE_ROOT="${SCRIPT_DIR}/.."

pushd "${MODULE_ROOT}/${ENV_DIR}" >/dev/null

echo "Initializing Terraform in ${ENV_DIR}..."
terraform init

echo "Applying Terraform in ${ENV_DIR}..."
terraform apply -auto-approve

popd >/dev/null
echo "Deployment complete."