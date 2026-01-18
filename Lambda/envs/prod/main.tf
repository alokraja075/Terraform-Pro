provider "aws" {
  region = var.region
}

module "lambda" {
  source        = "../../modules/lambda"
  function_name = var.function_name
  runtime       = var.runtime
  handler       = var.handler

  source_dir = "${path.cwd}/src"
  build_dir  = "${path.cwd}/build"

  timeout     = var.timeout
  memory_size = var.memory_size

  environment = var.environment
  tags        = var.tags
}

output "lambda_arn" {
  value = module.lambda.function_arn
}
