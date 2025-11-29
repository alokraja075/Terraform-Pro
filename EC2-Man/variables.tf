variable "region_name" {
  description = "Region Name"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Key pair name"
  type        = string
  default     = "Instance-KP"
}

variable "allowed_cidr" {
  description = "Allowed CIDR"
  type        = string
  default     = "0.0.0.0/0"
}
