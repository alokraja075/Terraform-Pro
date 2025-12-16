variable "security_groups" {
  description = "Map of security groups to create"
  type = map(object({
    description   = string
    ingress_ports = set(number)
  }))
  default = {
    web = {
      description   = "Allow SSH and HTTP"
      ingress_ports = [22, 80, 8000, 443]
    }
  }
}

variable "launch_templates" {
  description = "Map of launch templates to create"
  type = map(object({
    ami           = string
    instance_type = string
    user_data     = string
    sg_key        = string
  }))
  default = {
    web = {
      ami           = ""
      instance_type = ""
      user_data     = ""
      sg_key        = "web"
    }
  }
}

variable "autoscaling_groups" {
  description = "Map of autoscaling groups to create"
  type = map(object({
    lt_key                = string
    min_size              = number
    max_size              = number
    desired_capacity      = number
    subnet_ids            = list(string)
    name                  = string
  }))
  default = {
    web = {
      lt_key           = "web"
      min_size         = 2
      max_size         = 3
      desired_capacity = 2
      subnet_ids       = []
      name             = ""
    }
  }
}
variable "name" {
  type    = string
  default = "app"
}
variable "ami" {
  type = string
  default = "ami-0c02fb55956c7d316"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
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