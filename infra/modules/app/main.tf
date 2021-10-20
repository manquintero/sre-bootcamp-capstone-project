locals {
  # Application
  app_name              = "api"
  container_name        = "sre-bootcamp"
  host_port             = 8080
  container_port        = 8000
  server_protocol       = "HTTP"
  ec2_health_check_type = "ELB"
  # Database
  db_username = "secret"
}

module "alb" {
  source = "../networking/alb"

  alb_name    = "${var.project}-${var.environment}"
  vpc_id      = var.vpc_id
  subnet_ids  = var.alb_subnet_ids
  environment = var.environment
}

module "bastion" {
  source = "../networking/bastion"

  vpc_id              = var.vpc_id
  vpc_zone_identifier = var.bastion_vpc_zone_identifier
  internal_networks   = var.bastion_internal_networks
  environment         = var.environment
}

resource "aws_lb_target_group" "lbtg" {
  name     = "${var.project}-lbtg"
  port     = local.host_port
  protocol = local.server_protocol
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = module.alb.alb_http_listener_arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lbtg.arn
  }
}

module "ecr" {
  source     = "../container/ecr"
  repository = "academy-${var.project}-manuel-quintero"
}

module "secrets" {
  source = "../secrets/manager"

  project     = var.project
  environment = var.environment
}

module "datastore" {
  source = "../datastore/mysql"

  # Tags
  environment = var.environment

  # Attributes
  identifier_prefix         = "${var.project}-${var.environment}"
  final_snapshot_identifier = "${var.project}-${var.environment}-final"
  db_username               = local.db_username
  instance_class            = var.db_instance_class
  db_password_secret_id     = module.secrets.db_password_secret_arn

  # Networking and security
  vpc_id                 = var.vpc_id
  db_subnets             = var.db_subnets
  publicly_accessible    = true
  vpc_security_group_ids = module.asg.aws_security_group_ecs_sg_id
}

module "ecs" {
  source = "../cluster/ecs"
  # Cluster
  environment      = var.environment
  app_name         = local.app_name
  container_port   = local.container_port
  container_name   = local.container_name
  container_image  = module.ecr.repository_url
  container_memory = var.ecs_container_memory
  container_cpu    = var.ecs_container_cpu
  container_tag    = var.ecs_container_tag
  db_host          = module.datastore.address
  db_username      = local.db_username
  host_port        = local.host_port
  desired_count    = var.ecs_desired_count
  # Load Balancer
  aws_lb_target_group_arn = aws_lb_target_group.lbtg.arn
  # Roles
  db_password_arn = module.secrets.db_password_secret_arn
}

module "asg" {
  source = "../cluster/asg"

  # Module config
  vpc_id                    = var.vpc_id
  alb_security_group_id     = module.alb.security_group_id
  bastion_security_group_id = module.bastion.security_group_id
  key_name                  = module.bastion.key_name
  # Launch configuration
  instance_type        = var.asg_instance_type
  cluster_name         = module.ecs.cluster_name
  host_port            = local.host_port
  launch_config_prefix = local.app_name
  # Auto-Scale
  vpc_zone_identifier = var.asg_vpc_zone_identifier
  target_group_arns   = [aws_lb_target_group.lbtg.arn]
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  health_check_type   = local.ec2_health_check_type
  enable_autoscaling  = false
}

module "lambda" {
  source = "../lambda"
}