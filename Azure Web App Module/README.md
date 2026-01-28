# Azure Web App Module

Provision an Azure Linux Web App and deploy a minimal Node.js application using Terraform. The app package is zipped locally and uploaded to Azure Storage; the Web App runs it via `WEBSITE_RUN_FROM_PACKAGE`.

## Prerequisites
- Terraform `>= 1.4`
- AzureRM provider auth via one of:
  - Azure CLI (`az login`) and default subscription
  - Or environment vars: `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`

## Structure
- modules/webapp: Terraform module creating RG, Service Plan, Storage, and Web App
- modules/webapp/app: Minimal Node app zipped and deployed
- envs/dev and envs/prod: Example environments wiring the module
- scripts/deploy.sh: Helper to init/apply

## Quickstart (Dev)
```bash
cd "Azure Web App Module"
./scripts/deploy.sh envs/dev
```

On success, Terraform outputs `webapp_url`. Open it in your browser.

## Customize
- Change `envs/*/terraform.tfvars` for region, naming, SKU, etc.
- Update `modules/webapp/app/*` to use your own app; Terraform will re-zip and redeploy.

## Notes
- Deployment uses Azure Storage SAS; the blob remains private.
- Runtime is Node `18-lts`. You can switch stacks in `modules/webapp/main.tf` via `site_config.application_stack`.