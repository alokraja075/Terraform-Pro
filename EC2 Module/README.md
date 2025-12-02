# Terraform Modular Repo (env wrappers)

This repo demonstrates the **Modular repo with top-level env wrappers** pattern.

Structure:
- `modules/ec2` : reusable EC2 module
- `envs/dev` and `envs/prod` : environment wrappers with their own backend configs
- `scripts/deploy.sh` : helper to deploy an environment

Usage:
1. Edit `envs/*/terraform.tfvars` with correct AMI and other values.
2. Ensure your S3 backend bucket and DynamoDB lock table exist.
3. Run (example for dev):
   ```
   cd envs/dev
   terraform init -reconfigure
   terraform plan -var-file=terraform.tfvars
   terraform apply -var-file=terraform.tfvars
   ```
