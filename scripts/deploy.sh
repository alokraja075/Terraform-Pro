#!/usr/bin/env bash
set -euo pipefail

ENV=${1:-dev}
cd "envs/${ENV}"
terraform init -reconfigure
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars" -auto-approve
