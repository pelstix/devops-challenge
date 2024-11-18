resource "time_sleep" "wait_for_master" {
  depends_on = [var.master]
  create_duration = "5m"  # 5-minute delay before worker nodes are created
}



# Create a launch template for worker nodes in the Kubernetes cluster
resource "aws_launch_template" "worker_lt" {
  name_prefix   = "bird-app"
  image_id       = var.worker_ami_id
  instance_type  = var.instance_type
  vpc_security_group_ids = var.vpc_security_group_ids 
  key_name       = var.key_name
  user_data = base64encode(file("userdata-worker.sh"))


   block_device_mappings {
    device_name = "/dev/sda1" 
    ebs {
      volume_size = 100  
      volume_type = "gp2"  
    }
   }




  # Ensure that the launch template is created before the worker instances
  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "bird-app-workerinstance"
    }
  }
}


# Create an Auto Scaling group for the worker nodes in the Kubernetes cluster
resource "aws_autoscaling_group" "worker_asg" {
  depends_on = [time_sleep.wait_for_master]
  vpc_zone_identifier = [var.private_subnet_id]
  min_size                = 1
  max_size                = 2
  desired_capacity        = 1
  health_check_type       = "EC2"
  health_check_grace_period = 300
  launch_template {
    id      = aws_launch_template.worker_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "k8s-worker"
    propagate_at_launch = true
  }
}

# Define a policy to scale up the number of instances in the worker Auto Scaling Group
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment      = 1
  adjustment_type         = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name  = aws_autoscaling_group.worker_asg.name
}

# Define a policy to scale down the number of instances in the worker Auto Scaling Group
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  scaling_adjustment      = -1
  adjustment_type         = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name  = aws_autoscaling_group.worker_asg.name
}

resource "aws_autoscaling_attachment" "worker_attachment" {
  autoscaling_group_name = aws_autoscaling_group.worker_asg.name
  lb_target_group_arn   = var.alb
}

resource "aws_autoscaling_attachment" "worker_attachment_2" {
  autoscaling_group_name = aws_autoscaling_group.worker_asg.name
  lb_target_group_arn   = var.alb_2
}

