# terraform {
#   backend "s3" {
#     bucket = "sre-bootcamp-capstone-project-terraform"
#     key    = "devel/services/ecs-example/terraform.tfstate"
#     region = "us-east-2"

#     dynamodb_table = "sre-bootcamp-capstone-project-terraform-locks"
#     encrypt        = true
#   }
# }

provider "aws" {
  region = "us-east-2"
}

locals {
  environment    = "dev"
  app_name       = "api"
  name           = "sre-bootcamp"
  resource_name  = "${local.name}-${local.environment}"
  container_port = 80
  # container_port = 8000
  host_port = 8080
  # host_port             = 80
  container_name  = "sre-bootcamp"
  container_image = "nginx:latest"
  # container_image       = "manquintero/academy-sre-bootcamp-manuel-quintero:latest"
  server_protocol       = "HTTP"
  ec2_min_size          = 2
  ec2_max_size          = 2
  ec2_health_check_type = "ELB"
  desired_ecs_count     = 2
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${local.name}-vpc"

  cidr = "10.0.0.0/24"

  azs              = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  public_subnets   = ["10.0.0.0/27", "10.0.0.32/27"]
  private_subnets  = ["10.0.0.64/27", "10.0.0.96/27"]
  database_subnets = ["10.0.0.128/27", "10.0.0.160/27"]

  # Public access to RDS instances
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  # One NAT Gateway per subnet (default behavior)
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  tags = {
    Environment = local.environment
    Name        = local.name
  }
}

module "alb" {
  source = "../../../modules/networking/alb"

  alb_name    = "${local.name}-${local.environment}"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.public_subnets
  environment = local.environment
}

resource "aws_lb_target_group" "lbtg" {
  name     = "${local.name}-lbtg"
  port     = local.host_port
  protocol = local.server_protocol
  vpc_id   = module.vpc.vpc_id

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

module "ecs" {
  source = "../../../modules/cluster/ecs"
  # ECR
  repository = "academy-${local.name}-manuel-quintero"
  # Cluster
  app_name        = local.app_name
  container_port  = local.container_port
  container_name  = local.container_name
  container_image = local.container_image
  host_port       = local.host_port
  desired_count   = local.desired_ecs_count
  # Load Balancer
  aws_lb_target_group_arn = aws_lb_target_group.lbtg.arn
}

module "asg" {
  source = "../../../modules/cluster/asg"

  # Module config
  vpc_id                = module.vpc.vpc_id
  alb_security_group_id = module.alb.alb_security_group_id
  # Launch configuration
  instance_type        = "t2.micro"
  cluster_name         = module.ecs.cluster_name
  host_port            = local.host_port
  launch_config_prefix = local.app_name
  # Auto-Scale
  vpc_zone_identifier = module.vpc.public_subnets
  target_group_arns   = [aws_lb_target_group.lbtg.arn]
  min_size            = local.ec2_min_size
  max_size            = local.ec2_max_size
  health_check_type   = local.ec2_health_check_type
}

# module "data-store" {
#   source = "../../../modules/data-store/mysql"

#   # Tags
#   environment = local.environment

#   # Attributes
#   identifier_prefix         = local.resource_name
#   final_snapshot_identifier = "${local.resource_name}-final"
#   db_username               = "secret"
#   instance_class            = "db.t2.micro"
#   db_password               = var.db_password

#   # Networking and security
#   db_subnets             = module.vpc.database_subnets
#   publicly_accessible    = true
#   vpc_security_group_ids = [module.asg.aws_security_group_rds_sg_id]
#   # vpc_security_group_ids = [module.asg.aws_security_group_rds_sg_id, module.asg.aws_security_group_ecs_sg_id]
# }