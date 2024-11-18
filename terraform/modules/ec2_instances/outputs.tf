output "k8s_master_instance_id" {
  value = aws_instance.k8s_master.id
}

output "k8s_bastion_instance_id" {
  value = aws_instance.bastion_host.id
}
