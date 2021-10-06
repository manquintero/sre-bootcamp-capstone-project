locals {
  any_port     = 0
  https_port   = 443
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

# For now we only use the AWS ECS optimized ami <https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html>
data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
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
  image_id                    = data.aws_ami.amazon_linux_ecs.id
  instance_type               = var.instance_type
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
  # Explicitly depend on the launch configuration's name so each time it's replaced this ASG is also replaced
  name = "${var.cluster_name}-${aws_launch_configuration.ecs_launch_config.name}"

  vpc_zone_identifier  = var.vpc_zone_identifier
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  min_size = var.min_size
  max_size = var.max_size

  # Wait for at least this many instances to pass health checks before considering the ASG deployment complete
  # min_elb_capacity = var.min_size

  # Configure integrations with a load balancer
  target_group_arns = var.target_group_arns
  health_check_type = var.health_check_type

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }
}