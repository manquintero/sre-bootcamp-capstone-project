locals {
  any_port     = 0
  ssh_port     = 22
  tcp_protocol = "tcp"
  any_protocol = "-1"
  all_ips      = ["0.0.0.0/0"]
  # EC2
  bastion_name = lower("bastion-${var.environment}")
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "${local.bastion_name}-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD3JYHWXKVZnSn10XqlGcHWE1WvLqctuKvXmBlkmgQ+kbRGNLQU9R9B958WH5ay0t0LDwNlZA4iWsKWBl3efcF0BCktETaK3MwkUB6JIOz9Yz4/RqPG36o4iN445UDNnoJbPCULLNhXLrWx9lwJov7UZNemV3+8NCoIya1iqQTYWxz/8cj8e4r/WJs2EvKayyt/MfBarYzZledhI7/MOPYODMhPGJcaItDOCq3jr1xmhPTNrWPJ/bHR/iz+aVkOpuwWy3PbpZF1P2uw+Orfy5qSWqhVLcUpKvTnd+AujCS4E0DPuIGKgrXrCVzX6flrK7RExbGdRzNoVC66/aKXxdyr3DYS4ZWbGHaEIfXatKLu67mgniiQyFRviNKNXxW1QMsl9YlmpYKPJ7SvLkvGt1lHqyw9aHZpjjEZstnSF9WOJkKudyiKrbgfe9MgyUWK/b4f0JseexkF4iI9v7bhNkZ/UWt6rlecPGWbv2CtWWSwwjKyvBVl3tDbP3BzGhVyspK2gMvjmD0qn8cNdtAGyxhh1tV4zOiOx9pT/v/lDOi08yGHRixljJK653iQC+iBp69IsSyVf2n/aOE4r0cOdH+aD4j5dD9gyWKpgGGI8BGBdIEqoV+gP1xUKvy4YUWZdS9SUHsZNWHwKdxxE+EZT+Mhc83s+U4w0cjxFKEjSgdYSQ== man.quintero@gmail.com"
}

resource "aws_security_group" "bastion_sg" {
  name        = "${local.bastion_name}-sg"
  description = "Security Group to allow minimal access to an instance"
  vpc_id      = var.vpc_id
}

# Allow the containers to receive SSH connections
resource "aws_security_group_rule" "service_in_bastion" {
  description = "Allow inbound SSH connections from the world"
  type        = "ingress"

  from_port   = local.ssh_port
  to_port     = local.ssh_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips

  security_group_id = aws_security_group.bastion_sg.id
}

# Allow intranet traffic
resource "aws_security_group_rule" "intranet" {
  description = "Allow all traffic in the intranet"
  type        = "egress"

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = var.internal_networks

  security_group_id = aws_security_group.bastion_sg.id
}

# Allow internet egress traffic to install tools
resource "aws_security_group_rule" "internet" {
  description = "Allow all traffic in the intranet"
  type        = "egress"

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips

  security_group_id = aws_security_group.bastion_sg.id
}

resource "aws_launch_configuration" "bastions_lc" {
  name_prefix                 = "bastions-"
  image_id                    = var.image_id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.bastion_key.key_name
  associate_public_ip_address = true

  # Install user programs
  user_data = data.template_file.user_data.rendered

  # Security
  security_groups = [aws_security_group.bastion_sg.id]

  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastions_asg" {
  # Explicitly depend on the launch configuration's name so each time it's replaced this ASG is also replaced
  name                 = "${aws_launch_configuration.bastions_lc.name}-${var.environment}-instance"
  launch_configuration = aws_launch_configuration.bastions_lc.name

  # Capacity and Allocation
  vpc_zone_identifier = var.vpc_zone_identifier
  desired_capacity    = length(var.vpc_zone_identifier)
  max_size            = length(var.vpc_zone_identifier)
  min_size            = 1

  # Health
  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = local.bastion_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}

data "aws_instances" "bastion_instances" {
  # Filters
  instance_tags = {
    Name = local.bastion_name
  }
  instance_state_names = ["running"]

  # Avoid concurrency issues on first execution
  depends_on = [
    aws_autoscaling_group.bastions_asg
  ]
}