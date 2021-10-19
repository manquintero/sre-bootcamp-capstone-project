terraform {
  backend "s3" {
    bucket = "sre-bootcamp-capstone-project-terraform"
    key    = "devel/services/app/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "sre-bootcamp-capstone-project-terraform-locks"
    encrypt        = true
  }
}

locals {
  environment = "dev"
  name        = "sre-bootcamp"
}
provider "aws" {
  region = "us-east-2"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name             = "${local.name}-vpc"
  cidr             = "10.0.0.0/24"
  azs              = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  public_subnets   = ["10.0.0.0/26", "10.0.0.64/26"]
  private_subnets  = ["10.0.0.128/27", "10.0.0.160/27"]
  database_subnets = ["10.0.0.192/27", "10.0.0.224/27"]

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

module "app" {
  source = "../../../modules/app"

  project     = local.name
  environment = local.environment

  # Networking
  vpc_id                    = module.vpc.vpc_id
  alb_subnet_ids            = module.vpc.public_subnets
  bastion_subnet_id         = module.vpc.public_subnets[0] # Allocate the bastion in the first public IP
  bastion_internal_networks = module.vpc.private_subnets_cidr_blocks
  # Elastic Container Service
  ecs_desired_count    = 2
  ecs_container_memory = 128
  ecs_container_cpu    = 10
  # Auto Scaling Group
  asg_vpc_zone_identifier = module.vpc.private_subnets
  asg_min_size            = 2
  asg_max_size            = 2
  asg_instance_type       = "t2.micro"
  # Database
  db_subnets = module.vpc.database_subnets
}