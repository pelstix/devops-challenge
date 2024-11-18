output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_id" {
  value = module.network.public_subnet_id
}

output "private_subnet_id" {
  value = module.network.private_subnet_id
}

output "k8s_sg_id" {
  value = module.security_groups.k8s_sg_id
}

output "worker_sg_id" {
  value = module.security_groups.worker_sg_id
}

output "bastion_sg_id" {
  value = module.security_groups.bastion_sg_id
}

output "asg_name" {
  value = module.autoscaling.asg_name
}


