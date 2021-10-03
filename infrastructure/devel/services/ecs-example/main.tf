terraform {
  backend "s3" {
    bucket = "sre-bootcamp-capstone-project-terraform"
    key    = "devel/services/ecs-example/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "sre-bootcamp-capstone-project-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}

locals {
  environment   = "dev"
  name          = "sre-bootcamp"
  resource_name = "${local.name}-${local.environment}"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "Test"

  cidr = "10.0.0.0/24"

  azs              = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  public_subnets   = ["10.0.0.0/26", "10.0.0.64/26"]
  database_subnets = ["10.0.0.128/26", "10.0.0.192/26"]

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

module "asg" {
  source     = "../../../modules/cluster/asg"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
}

# module "ecs" {
#   source = "../../../modules/cluster/ecs"
# }

module "data-store" {
  source = "../../../modules/data-store/mysql"

  # Tags
  environment = local.environment

  # Attributes
  identifier_prefix         = local.resource_name
  final_snapshot_identifier = "${local.resource_name}-final"
  db_username               = "secret"
  instance_class            = "db.t2.micro"
  db_password               = var.db_password

  # Networking and security
  db_subnets             = module.vpc.database_subnets
  publicly_accessible    = true
  vpc_security_group_ids = [module.asg.aws_security_group_rds_sg_id]
  # vpc_security_group_ids = [module.asg.aws_security_group_rds_sg_id, module.asg.aws_security_group_ecs_sg_id]
}