variable "private_subnet_id" {
  description = "ID of the private subnet to associate with the worker instances."
  type        = string
}


variable "vpc_security_group_ids" {
  description = "List of security group IDs for the VPC"
  type        = list(string)
}


variable "instance_type" {
  default = "t3.medium"
}

variable "key_name" {
  description = "Name of the SSH key"
  default     = "pelumi-lifinance"
}

variable "worker_ami_id" {
  description = "The ID of the AMI to use for the EC2 instances"
  type        = string
  default     = "ami-07d20571c32ba6cdc"  
}

variable "alb" {
  description = "ID of alb 1"
  type        = string
}

variable "alb_2" {
  description = "ID of alb 2"
  type        = string
}

variable "master" {
  description = "master instance"
  type        = string
}


