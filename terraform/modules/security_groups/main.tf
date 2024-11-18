# Define a security group for the Kubernetes cluster master node
resource "aws_security_group" "k8s_sg" {
  vpc_id = var.vpc_id

  description = "Kubernetes cluster security group"

  # Allow SSH access to the master node from the bastion host
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # allow access to clusterview
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  
  }
   
   # Allow communication between master and worker nodes

   ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    security_groups = [aws_security_group.worker_sg.id]
  
  }

  # Allow outbound traffic to any destination
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define a security group for the worker nodes
resource "aws_security_group" "worker_sg" {
  vpc_id = var.vpc_id
  description = "Security group for worker nodes"

  # Ingress rule to allow SSH (port 22) access from the bastion host
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
    
   # Ingress rule to allow all TCP traffic within the private subnet (workers can communicate with each other)

   ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }

   ingress {
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

   ingress {
    from_port   = 32000
    to_port     = 32000
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  
   # Egress rule to allow all outbound traffic (any port, any protocol)
   egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define a security group for the bastion host
resource "aws_security_group" "bastion_sg" {
  vpc_id = var.vpc_id
  description = "Security group for Bastion Host"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]  
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define a security group for the ALB
resource "aws_security_group" "alb_sg" {
  vpc_id = var.vpc_id
  description = "Security group for Application Load Balancer"

  # Allow inbound HTTP and HTTPS traffic from the internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic to any destination
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}






