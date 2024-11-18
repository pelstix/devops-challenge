resource "time_sleep" "wait_for_bastion" {
  depends_on = [aws_instance.bastion_host]
  create_duration = "2m"  # 2-minute delay before worker nodes are created
}

# Define the master node instance for the Kubernetes cluster
resource "aws_instance" "k8s_master" {
  depends_on = [time_sleep.wait_for_bastion]
  ami                    = var.master_ami_id
  instance_type          = var.instance_type
  private_ip = var.private_ip
  subnet_id =  var.private_subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids_1
  key_name               = var.key_name
  
  user_data = file("userdata.sh")

  root_block_device {
    volume_size = 100  
    volume_type = "gp2"  
    delete_on_termination = true  
  }

  tags = {
    Name = "k8s-master"
  }
}

# Define an EC2 instance for the bastion host
resource "aws_instance" "bastion_host" {
  ami             = var.bastion_ami_id
  instance_type   = "t2.micro"
  private_ip = var.private_ip_bastion
  subnet_id = var.public_subnet_id
  key_name        = var.bastion_key_name

  vpc_security_group_ids = var.vpc_security_group_ids_2
  root_block_device {
    volume_size = 100  
    volume_type = "gp2"  
    delete_on_termination = true  
  }

  tags = {
    Name = "bastion"
  }
}
