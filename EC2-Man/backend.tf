terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-alokr-2025" # your actual bucket name
    key            = "dev/terraform.tfstate"             # this is the state file path
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
