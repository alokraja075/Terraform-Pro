variable "region" {
  type    = string
  default = "us-east-1"
}
variable "name" {
  type    = string
  default = "prod-app"
}
variable "ami" {
  type = string
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "subnet_ids" {
  description = "List of subnet IDs to deploy in prod"
  type        = list(string)
  default     = ["subnet-02a7d1c1b59b50040", "subnet-087cdbcdd03331571","subnet-0755652f55491ce4e"]
}
