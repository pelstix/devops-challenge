

variable "vpc_security_group_ids_1" {
  description = "List of security group IDs for the VPC"
  type        = list(string)
}

variable "vpc_security_group_ids_2" {
  description = "List of security group IDs for the VPC"
  type        = list(string)
}



variable "public_subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "private_subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "instance_type" {
  default = "t3.large"
}

variable "key_name" {
  description = "Name of the SSH key"
  default     = "pelumi-lifinance"
}

variable "bastion_key_name" {
  description = "Name of the SSH key"
  default     = "bastion-key"
}


variable "master_ami_id" {
  description = "The ID of the AMI to use for the EC2 instances"
  type        = string
  default     = "ami-07d20571c32ba6cdc"  
  
}

variable "bastion_ami_id" {
  description = "The ID of the AMI to use for the EC2 instances"
  type        = string
  default     = "ami-09055b5bbbbbf13c5"  
}

variable "private_ip" {
  default = "10.0.2.5"
  type    = string
}

variable "private_ip_bastion" {
  default = "10.0.1.5"
  type    = string
}
