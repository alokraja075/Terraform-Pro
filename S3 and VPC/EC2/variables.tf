variable "region_name" {
  description = "AWS Region (e.g. us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name for the AWS key pair"
  type        = string
  default     = "ec2-deployer-key"
}

variable "allowed_cidr" {
  description = "CIDR range allowed to access the instance (SSH and HTTP). Set to your IP for security."
  type        = string
  default     = "0.0.0.0/0"
}

variable "private_key_path" {
  description = "Path to write the generated private key (local file)"
  type        = string
  default     = "ec2_deployer_key.pem"
}

variable "create_key" {
  description = "Whether to generate and upload a key pair (set false if you will provide an existing key_name)"
  type        = bool
  default     = true
}
