terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-alokr-2025"
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
