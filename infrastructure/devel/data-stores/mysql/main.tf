terraform {
  backend "s3" {
    bucket = "sre-bootcamp-capstone-project-terraform"
    key    = "devel/data-stores/mysql/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "sre-bootcamp-capstone-project-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}

locals {
  name           = "sre-bootcamp"
  environment    = "devel"
  resources_name = "${local.name}-db-${local.environment}"
}

module "datastore_mysql" {
  source            = "../../../modules/data-store/mysql"
  db_instance_name  = local.resources_name
  db_instance_class = "db.t2.micro"
  db_username       = "secret"
  db_password       = var.db_password
}