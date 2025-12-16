variable "region_name" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default = "my-last-bucket-form-terraform-2025-unique123"
}
