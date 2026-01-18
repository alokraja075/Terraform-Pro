variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "function_name" {
  description = "Lambda function name"
  type        = string
  default     = "hello-python-lambda-prod"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "handler" {
  description = "Lambda handler"
  type        = string
  default     = "app.lambda_handler"
}

variable "timeout" {
  description = "Lambda timeout"
  type        = number
  default     = 10
}

variable "memory_size" {
  description = "Lambda memory size"
  type        = number
  default     = 128
}

variable "environment" {
  description = "Environment variables"
  type        = map(string)
  default     = {
    APP_ENV = "prod"
  }
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {
    Project = "Terraform-Pro"
    Module  = "Lambda"
    Env     = "prod"
  }
}
