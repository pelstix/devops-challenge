variable "security_groups" {
  description = "List of security group IDs for the VPC"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be created."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "subnet_id_b" {
  description = "Subnet ID"
  type        = string
}

