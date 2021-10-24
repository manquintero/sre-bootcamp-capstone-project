locals {
  any_port     = 0
  https_port   = 443
  ssh_port     = 22
  tcp_protocol = "tcp"
  any_protocol = "-1"
  all_ips      = ["0.0.0.0/0"]
}

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user-data.sh")

  vars = {
    cluster_name = var.cluster_name
  }
}

# Allow the LB to send packets to the containers
resource "aws_security_group_rule" "lb_out" {
  description = "Allow outbound connections from the LB to ECS service"

  type                     = "egress"
  from_port                = var.host_port
  to_port                  = var.host_port
  protocol                 = local.tcp_protocol
  source_security_group_id = var.alb_security_group_id

  security_group_id = aws_security_group.ecs_sg.id
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "Elastic Container Service Security Group"
  vpc_id      = var.vpc_id
}

# Allow the containers to receive packets from the LB
resource "aws_security_group_rule" "service_in_lb" {
  description = "Allow inbound TCP connections from the LB to ECS service"

  type                     = "ingress"
  from_port                = var.host_port
  to_port                  = var.host_port
  protocol                 = local.tcp_protocol
  source_security_group_id = var.alb_security_group_id

  security_group_id = aws_security_group.ecs_sg.id
}

resource "aws_security_group_rule" "service_in_bastion" {
  description = "Allow inbound TCP connections from the Bastions to ECS service"

  type        = "ingress"
  from_port   = var.host_port
  to_port     = var.host_port
  protocol    = local.tcp_protocol
  cidr_blocks = var.public_networks

  security_group_id = aws_security_group.ecs_sg.id
}

# Allow all outbound traffic from the containers. This is necessary
# to support pulling Docker images from Dockerhub and ECR.
resource "aws_security_group_rule" "service_out" {
  description = "Allow outbound connections for all protocols and all ports for ECS service"
  type        = "egress"

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips

  security_group_id = aws_security_group.ecs_sg.id
}

# Allow inbound SSH connections from the internal networks
resource "aws_security_group_rule" "ssh_in" {
  count       = var.enable_ssh_in ? 1 : 0
  description = "Allow inbound connections for SSH protocol from the internal network"
  type        = "ingress"

  from_port                = local.ssh_port
  to_port                  = local.ssh_port
  protocol                 = local.tcp_protocol
  source_security_group_id = var.bastion_security_group_id

  security_group_id = aws_security_group.ecs_sg.id
}

resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.ecs_agent.name
}

resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_launch_configuration" "ecs_launch_config" {
  name_prefix                 = "${var.launch_config_prefix}-"
  image_id                    = var.image_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  security_groups      = [aws_security_group.ecs_sg.id]
  user_data            = data.template_file.user_data.rendered

  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name_prefix = var.cluster_name

  vpc_zone_identifier  = var.vpc_zone_identifier
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  min_size = var.min_size
  max_size = var.min_size * 2

  # Wait for at least this many instances to pass health checks before considering the ASG deployment complete
  min_elb_capacity          = var.min_size
  wait_for_capacity_timeout = "20m"

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  # Configure integrations with a load balancer
  target_group_arns = var.target_group_arns
  health_check_type = var.health_check_type

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = var.enable_autoscaling_schedule ? 1 : 0

  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *"

  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = var.enable_autoscaling_schedule ? 1 : 0

  scheduled_action_name = "scale-in-at-night"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"

  autoscaling_group_name = aws_autoscaling_group.asg.name
}