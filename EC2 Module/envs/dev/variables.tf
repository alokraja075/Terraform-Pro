variable "region" {
  type    = string
  default = "us-east-1"
}
variable "name" {
  type    = string
  default = "dev-app"
}
variable "ami" {
  type    = string
  default = "ami-0ecb62995f68bb549"
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "key_pair_name" {
  description = "Key pair name"
  type        = string
  default     = "Dev-KP"
}
variable "subnet_ids" {
  description = "List of subnet IDs to deploy to"
  type        = list(string)
  default     = ["subnet-02a7d1c1b59b50040", "subnet-087cdbcdd03331571", "subnet-0755652f55491ce4e"]
}