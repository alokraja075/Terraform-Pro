# AWS Lambda Terraform Module

This Terraform module provides a streamlined way to deploy AWS Lambda functions with Python runtime. It handles function packaging, IAM roles, and environment configuration.

## 📁 Project Structure

```
Lambda/
├── readme.md                 # This file
├── envs/                     # Environment-specific configurations
│   ├── dev/
│   │   ├── main.tf          # Dev environment Lambda configuration
│   │   ├── variables.tf     # Dev environment variables
│   │   ├── src/             # Python source code
│   │   │   └── app.py       # Lambda handler function
│   │   └── build/           # Build artifacts (auto-generated)
│   └── prod/
│       ├── main.tf          # Production environment configuration
│       ├── variables.tf     # Production environment variables
│       ├── src/             # Python source code
│       │   └── app.py       # Lambda handler function
│       └── build/           # Build artifacts (auto-generated)
├── modules/
│   └── lambda/
│       ├── main.tf          # Lambda module resources
│       ├── variables.tf     # Module input variables
│       ├── outputs.tf       # Module outputs
│       ├── versions.tf      # Terraform version constraints
│       └── README.md        # Module documentation
└── scripts/
    └── deploy.sh            # Deployment automation script
```

## 🚀 Features

- **Automated Packaging**: Automatically zips Python source code for Lambda deployment
- **IAM Role Management**: Creates and attaches necessary IAM roles and policies
- **Environment Variables**: Supports custom environment variables for Lambda functions
- **Multi-Environment Support**: Separate dev and prod configurations
- **Configurable Runtime**: Supports Python 3.12 by default (configurable)
- **Resource Tagging**: Apply consistent tags across all resources

## 📋 Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with Lambda permissions
- jq (for deployment script)

## 🛠️ Module Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| function_name | Lambda function name | `string` | - | yes |
| runtime | Lambda runtime | `string` | `python3.12` | no |
| handler | Lambda handler | `string` | `app.lambda_handler` | no |
| timeout | Lambda timeout in seconds | `number` | `10` | no |
| memory_size | Lambda memory size in MB | `number` | `128` | no |
| environment | Environment variables for Lambda | `map(string)` | `{}` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |
| source_dir | Path to Python source directory | `string` | - | yes |
| build_dir | Path for build artifacts | `string` | `null` | no |

## 📤 Module Outputs

| Name | Description |
|------|-------------|
| function_arn | ARN of the Lambda function |
| function_name | Name of the Lambda function |
| role_arn | ARN of the IAM role |

## 🎯 Usage

### Quick Start with Deployment Script

```bash
# Deploy to dev environment
./scripts/deploy.sh dev

# Deploy to prod environment
./scripts/deploy.sh prod
```

### Manual Deployment

#### 1. Navigate to environment directory

```bash
cd envs/dev
```

#### 2. Customize your variables (optional)

Create a `terraform.tfvars` file or modify `variables.tf`:

```hcl
region        = "us-east-1"
function_name = "my-lambda-function"
runtime       = "python3.12"
handler       = "app.lambda_handler"
timeout       = 30
memory_size   = 256

environment = {
  ENVIRONMENT = "dev"
  LOG_LEVEL   = "INFO"
}

tags = {
  Environment = "dev"
  Project     = "MyProject"
  ManagedBy   = "Terraform"
}
```

#### 3. Initialize Terraform

```bash
terraform init
```

#### 4. Plan deployment

```bash
terraform plan
```

#### 5. Apply configuration

```bash
terraform apply
```

#### 6. Get Lambda ARN

```bash
terraform output lambda_arn
```

## 💻 Customizing Lambda Function

### Modify the Python Handler

Edit the `src/app.py` file in your environment directory:

```python
def lambda_handler(event, context):
    # Your custom logic here
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": "Hello from Python Lambda!"
    }
```

### Add Dependencies

If your Lambda requires external Python packages:

1. Create a `requirements.txt` in the `src/` directory
2. Modify the module to include a layer or package dependencies in the zip

## 🔧 Advanced Configuration

### Custom Runtime Configuration

```hcl
module "lambda" {
  source        = "../../modules/lambda"
  function_name = "advanced-lambda"
  runtime       = "python3.11"
  handler       = "custom.handler"
  timeout       = 60
  memory_size   = 512
  
  source_dir = "${path.cwd}/src"
  build_dir  = "${path.cwd}/build"
  
  environment = {
    API_KEY     = "your-api-key"
    DB_HOST     = "database.example.com"
    ENVIRONMENT = "production"
  }
  
  tags = {
    Application = "MyApp"
    CostCenter  = "Engineering"
  }
}
```

## 🗂️ Environment Management

### Development Environment (`envs/dev/`)
- Used for testing and development
- Typically lower memory/timeout settings
- Can use relaxed security policies

### Production Environment (`envs/prod/`)
- Production-ready configuration
- Higher resource allocations
- Stricter security and monitoring

## 🔐 IAM Permissions

The module creates an IAM role with the following permissions:
- `AWSLambdaBasicExecutionRole` - CloudWatch Logs permissions

To add additional permissions, modify the `modules/lambda/main.tf` file or create additional policy attachments.

## 🧹 Cleanup

To destroy Lambda resources:

```bash
cd envs/dev  # or prod
terraform destroy
```

## 📝 Notes

- Build artifacts are stored in the `build/` directory and are automatically generated
- The source code is automatically zipped during `terraform apply`
- Lambda function names must be unique within an AWS region
- Changes to the Python code will trigger a new deployment

## 🤝 Contributing

When adding new features:
1. Update both dev and prod environments
2. Test in dev before deploying to prod
3. Update this README with any new variables or outputs

## 📚 Additional Resources

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Python Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)

## 📄 License

See LICENSE file for details.