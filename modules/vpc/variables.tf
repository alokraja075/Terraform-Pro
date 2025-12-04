variable "name" {
  description = "Name prefix for VPC and resources"
  type        = string
  default     = "example-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to spread subnets across"
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets (one per AZ). If empty auto-generated from VPC CIDR"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "List of CIDRs for private subnets (one per AZ). If empty auto-generated from VPC CIDR"
  type        = list(string)
  default     = []
}

variable "enable_nat" {
  description = "Whether to create NAT gateways for private subnets"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
