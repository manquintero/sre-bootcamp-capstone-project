terraform {
  backend "s3" {
    bucket = "sre-bootcamp-capstone-project-terraform"
    key    = "staging/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "sre-bootcamp-capstone-project-terraform-locks"
    encrypt        = true
  }
}

locals {
  name   = "sre-bootcamp"
  region = "us-east-2"

  # Port binding
  ssh_port   = 22
  http_port  = 80
  https_port = 443
  # For the Load Balancer
  application_port = 8080

  # Networking
  public_subnets   = ["10.1.0.0/26", "10.1.0.64/26"]
  private_subnets  = ["10.1.0.128/27", "10.1.0.160/27"]
  database_subnets = ["10.1.0.192/27", "10.1.0.224/27"]
  network_acls = {
    # Allow Return traffic from the World
    default_inbound = [
      {
        rule_number = 900
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    # Allow Services to retrieve information
    default_outbound = [
      {
        rule_number = 900
        rule_action = "allow"
        from_port   = 32768
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    public_inbound = [
      # Load Balancer Entrypoint
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = local.http_port
        to_port     = local.http_port
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      # Required for ECS
      {
        rule_number = 101
        rule_action = "allow"
        from_port   = local.https_port
        to_port     = local.https_port
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      # Allow Connections to bastions
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = local.ssh_port
        to_port     = local.ssh_port
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      # Allow return traffic from the World
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 32768
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    # Allow querying http
    public_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = local.http_port
        to_port     = local.http_port
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      # Allow quering https
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = local.https_port
        to_port     = local.https_port
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      # Allow internal SSH from Bastions
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = local.ssh_port
        to_port     = local.ssh_port
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      # Allow Load Balancer to Connect to the Application Host
      {
        rule_number = 130
        rule_action = "allow"
        from_port   = local.application_port
        to_port     = local.application_port
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
  }
}

provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name             = "${local.name}-${var.environment}-vpc"
  cidr             = "10.1.0.0/24"
  azs              = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  public_subnets   = local.public_subnets
  private_subnets  = local.private_subnets
  database_subnets = local.database_subnets

  # ACLs
  public_dedicated_network_acl = true
  public_inbound_acl_rules     = concat(local.network_acls["default_inbound"], local.network_acls["public_inbound"])
  public_outbound_acl_rules    = concat(local.network_acls["default_outbound"], local.network_acls["public_outbound"])

  private_dedicated_network_acl = false

  # One NAT Gateway per subnet (default behavior)
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  # Database reachable via Domain Names
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = var.environment
    Name        = "${local.name}-${var.environment}"
  }
}

module "app" {
  source = "../../modules/app"

  project     = local.name
  environment = var.environment

  # Networking
  vpc_id                      = module.vpc.vpc_id
  alb_subnet_ids              = module.vpc.public_subnets
  bastion_internal_networks   = concat(module.vpc.private_subnets_cidr_blocks, module.vpc.database_subnets_cidr_blocks)
  bastion_vpc_zone_identifier = module.vpc.public_subnets
  # Elastic Container Service
  ecs_desired_count    = var.ecs_desired_count
  ecs_container_memory = var.ecs_container_memory
  ecs_container_cpu    = var.ecs_container_cpu
  ecs_container_tag    = var.container_tag
  ecs_host_port        = local.application_port
  # Auto Scaling Group
  asg_public_networks             = module.vpc.public_subnets_cidr_blocks
  asg_vpc_zone_identifier         = module.vpc.private_subnets
  asg_min_size                    = var.ecs_desired_count # The ASG needs to match the number of EC2
  asg_instance_type               = var.asg_instance_type
  asg_enable_autoscaling_schedule = var.asg_enable_autoscaling_schedule
  asg_enable_ssh_in               = var.asg_enable_ssh_in
  # Database
  db_subnets           = module.vpc.database_subnets
  db_internal_networks = concat(module.vpc.public_subnets_cidr_blocks, module.vpc.private_subnets_cidr_blocks)
}