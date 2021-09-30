terraform {
  backend "s3" {
    bucket = "sre-bootcamp-capstone-project-terraform"
    key    = "devel/services/webserver-cluster/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "sre-bootcamp-capstone-project-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}

locals {
  name = "sre-bootcamp"
  environment = "devel"
  resource_name = "${local.name}-${local.environment}"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name           = local.resource_name
  db_remote_state_bucket = "${local.name}-db-${local.environment}"
  db_remote_state_key    = "${local.environment}/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 2
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name

  cidr = "10.1.0.0/16"

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets  = ["10.1.11.0/24", "10.1.12.0/24"]

  enable_nat_gateway = false # false is just faster

  tags = {
    Environment = local.environment
    Name        = local.name
  }
}