# Create the Application Load Balancer
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = [var.subnet_id, var.subnet_id_b]  # Include both subnets
  enable_deletion_protection = false

  tags = {
    Name = "my-alb"
  }
}

# Create an HTTP listener for the ALB
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }

  tags = {
    Name = "http-listener"
  }
}

# create a target group
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 30080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "my-target-group"
  }
}

#Load balancer 2 for the application

# Create the Application Load Balancer
resource "aws_lb" "my_alb_2" {
  name               = "my-alb-2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = [var.subnet_id, var.subnet_id_b]  # Include both subnets
  enable_deletion_protection = false

  tags = {
    Name = "my-alb-2"
  }
}

# Create an HTTP listener for the ALB
resource "aws_lb_listener" "http_listener_2" {
  load_balancer_arn = aws_lb.my_alb_2.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group_2.arn
  }

  tags = {
    Name = "http-listener-2"
  }
}

# create a target group
resource "aws_lb_target_group" "my_target_group_2" {
  name     = "my-target-group-2"
  port     = 32000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "my-target-group-2"
  }
}

