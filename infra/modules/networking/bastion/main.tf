locals {
  any_port     = 0
  ssh_port     = 22
  tcp_protocol = "tcp"
  any_protocol = "-1"
  all_ips      = ["0.0.0.0/0"]
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD3JYHWXKVZnSn10XqlGcHWE1WvLqctuKvXmBlkmgQ+kbRGNLQU9R9B958WH5ay0t0LDwNlZA4iWsKWBl3efcF0BCktETaK3MwkUB6JIOz9Yz4/RqPG36o4iN445UDNnoJbPCULLNhXLrWx9lwJov7UZNemV3+8NCoIya1iqQTYWxz/8cj8e4r/WJs2EvKayyt/MfBarYzZledhI7/MOPYODMhPGJcaItDOCq3jr1xmhPTNrWPJ/bHR/iz+aVkOpuwWy3PbpZF1P2uw+Orfy5qSWqhVLcUpKvTnd+AujCS4E0DPuIGKgrXrCVzX6flrK7RExbGdRzNoVC66/aKXxdyr3DYS4ZWbGHaEIfXatKLu67mgniiQyFRviNKNXxW1QMsl9YlmpYKPJ7SvLkvGt1lHqyw9aHZpjjEZstnSF9WOJkKudyiKrbgfe9MgyUWK/b4f0JseexkF4iI9v7bhNkZ/UWt6rlecPGWbv2CtWWSwwjKyvBVl3tDbP3BzGhVyspK2gMvjmD0qn8cNdtAGyxhh1tV4zOiOx9pT/v/lDOi08yGHRixljJK653iQC+iBp69IsSyVf2n/aOE4r0cOdH+aD4j5dD9gyWKpgGGI8BGBdIEqoV+gP1xUKvy4YUWZdS9SUHsZNWHwKdxxE+EZT+Mhc83s+U4w0cjxFKEjSgdYSQ== man.quintero@gmail.com"
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
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


# For now we only use the AWS ECS optimized ami
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

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_ecs.id
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet_id
  key_name                    = aws_key_pair.bastion_key.key_name
  associate_public_ip_address = true

  # Security
  security_groups = [aws_security_group.bastion_sg.id]

  tags = {
    Name        = "Bastion ${var.environment}"
    Environment = var.environment
  }

}