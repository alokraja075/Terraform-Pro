<!-- Auto-created: capture of terraform apply failure and remediation notes -->
# Terraform apply failure: EC2 InvalidParameterCombination (instance type)

Date: 2025-11-29
Branch: feature/dev

Summary
- While applying the saved plan for `envs/dev`, `terraform apply` started creating the EC2 instance and failed with an AWS API error: `InvalidParameterCombination: The specified instance type is not eligible for Free Tier.`

Commands run (repro)
- cd /workspaces/Terraform-Pro/envs/dev
- terraform init
- terraform validate
- terraform plan -out plan.tfplan
- terraform apply -auto-approve "plan.tfplan"

Observed output (relevant excerpts)
---
╷
│ Error: creating EC2 Instance: operation error EC2: RunInstances, https response error StatusCode: 400, RequestID: ... , api error InvalidParameterCombination: The specified instance type is not eligible for Free Tier.
│ 
│   with module.app_ec2.aws_instance.web,
│   on ../../modules/ec2/main.tf line 25, in resource "aws_instance" "web":
│   25: resource "aws_instance" "web" {
│ 
╵
---

Additional warnings seen in the session
- Deprecated Parameter: The parameter `dynamodb_table` is deprecated. Use `use_lockfile` instead. (backend or lock config warning)
- Earlier CLI parsing note: "Too many command line arguments" appeared when the plan file and flags were passed in a way the Terraform version parsed unexpectedly. Correct command order used above.

Where the values came from
- Module defaults: `modules/ec2/variables.tf` default `instance_type = "t3.micro"`.
- Environment override: `envs/dev/variables.tf` sets `instance_type = "t2.micro"` (this is what appeared in the plan).
- AMI used: `envs/dev/terraform.tfvars` sets `ami = "ami-0c02fb55956c7d316"`.

Likely causes
- AWS account / region free-tier restrictions: the chosen `instance_type` may not be free-tier eligible in the target region or under the account constraints.
- AMI compatibility: some AMIs are constrained to certain virtualization/instance type families (for example, some marketplace or specialised AMIs are incompatible with smaller instance types).
- Temporary AWS-side constraints or account limits.

Remediation / next steps
1. Verify instance type eligibility and AMI compatibility:
   - Check whether the chosen `instance_type` is free-tier eligible in `us-east-1` (or change region):
     - aws cli: `aws ec2 describe-instance-types --filters Name=free-tier-eligible,Values=true --region us-east-1`
   - Confirm the AMI supports the instance type: check AMI virtualization and supported instance types in the AWS console or AMI documentation.
2. Quick repo-level fixes (pick one):
   - Change the environment instance default to a known-free-tier type supported by the AMI, e.g. update `envs/dev/variables.tf` to `instance_type = "t3.micro"` or another free-tier eligible type.
   - Remove the implicit expectation of Free Tier: choose a supported instance type explicitly in `envs/dev/main.tf` module block, e.g. `instance_type = "t3.small"` (costs may apply).
3. Address the deprecated backend parameter:
   - If you use a `dynamodb_table` setting in backend configuration, migrate to `use_lockfile` per Terraform provider/backends docs.

Suggested change snippet (example to force `t3.micro` in dev)
```hcl
# envs/dev/variables.tf
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
```

Why this file
- This document captures the CLI reproduction, the exact AWS error, where the values are set in the repo, and recommended immediate fixes so the team can triage without re-running apply.

Owner / Next action
- @alokraja075: confirm whether you want dev to use a specific instance type, or whether we should update the README/module docs to mention AMI<->instance compatibility.
