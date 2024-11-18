output "k8s_sg_id" {
  value = aws_security_group.k8s_sg.id
}

output "worker_sg_id" {
  value = aws_security_group.worker_sg.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}