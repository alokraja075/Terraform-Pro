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

variable "nat_gateway_strategy" {
  description = "NAT gateway deployment strategy: \"none\" | \"single\" | \"per_az\""
  type        = string
  default     = "none"
}

variable "single_nat_subnet_index" {
  description = "When using \"single\" nat_gateway_strategy, the public subnet index (0-based) to host the NAT gateway"
  type        = number
  default     = 0
}

variable "create_flow_logs" {
  description = "Whether to create VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_logs_traffic_type" {
  description = "Flow logs traffic type: ACCEPT, REJECT, or ALL"
  type        = string
  default     = "ALL"
}

variable "flow_logs_destination_type" {
  description = "Flow logs destination type: \"cloud-watch-logs\" or \"s3\""
  type        = string
  default     = "cloud-watch-logs"
}

variable "flow_logs_destination_arn" {
  description = "ARN of the destination (CloudWatch Log Group ARN or S3 bucket ARN) for flow logs"
  type        = string
  default     = ""
}

variable "enable_s3_endpoint" {
  description = "Create a gateway VPC endpoint for S3"
  type        = bool
  default     = false
}

variable "enable_dynamodb_endpoint" {
  description = "Create a gateway VPC endpoint for DynamoDB"
  type        = bool
  default     = false
}

variable "enable_network_acl" {
  description = "Whether to create basic network ACLs for public and private subnets"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
