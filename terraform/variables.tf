variable "region" {
  default = "eu-west-2"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "key_name" {
  description = "Name of the SSH key"
  default     = "pelumi-lifinance"
}

variable "bastion_key_name" {
  description = "Name of the SSH key"
  default     = "bastion-key"
}

variable "my_ip" {
  default = "0.0.0.0/0"  #change this to your public ip when testing :)
}

variable "master_ami_id" {
  description = "The ID of the AMI to use for the EC2 instances"
  type        = string
  default     = "ami-0ad495ce4f2ed9b75"  
  
}

variable "worker_ami_id" {
  description = "The ID of the AMI to use for the EC2 instances"
  type        = string
  default     = "ami-0d6c028147e542695"  
}

variable "bastion_ami_id" {
  description = "The ID of the AMI to use for the EC2 instances"
  type        = string
  default     = "ami-09055b5bbbbbf13c5"  
}
