variable "name" {
  type    = string
  default = "app"
}
variable "ingress_ports" {
  description = "List of ingress ports"
  type        = list(number)
  default     = [22, 80, 8000]
}
variable "ami" {
  type = string
  default = "ami-0c02fb55956c7d316"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "EC2_default_storage_size" {
  type = string
  default = "20"
}
variable "environments" {
  type        = string
  description = "Environment name (e.g., prod, dev)"
  default     = "dev"
}
variable "key_pair_name" {
  description = "Key pair name"
  type        = string
  default     = "Instance-KP"
}
variable "user_data" {
  description = "User data script to initialize the instance"
  type        = string
  default     = ""
}
variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = ["subnet-02a7d1c1b59b50040", "subnet-087cdbcdd03331571","subnet-0755652f55491ce4e"]
}
variable "vpc_id" {
  description = "VPC"
  type = string
  default = "vpc-0b7c7325fe49ba16c"
}