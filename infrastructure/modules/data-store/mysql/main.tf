# resource "aws_db_instance" "example" {
#   engine            = "mysql"
#   allocated_storage = var.db_allocated_storage
#   instance_class    = var.db_instance_class
#   name              = "${var.db_instance_name}-mysql"
#   username          = var.db_username
#   password          = var.db_password
# }

resource "aws_db_subnet_group" "public" {
  name       = "public"
  subnet_ids = var.db_subnets

  tags = {
    Name = "Public"
  }
}

resource "aws_db_instance" "mysql" {
  identifier_prefix       = var.identifier_prefix
  allocated_storage       = 5
  backup_retention_period = 2
  backup_window           = "01:00-01:30"
  maintenance_window      = "sun:03:00-sun:03:30"
  multi_az                = true
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = var.instance_class
  name                    = "bootcamp_tht"
  username                = var.db_username
  port                    = "3306"
  db_subnet_group_name    = aws_db_subnet_group.public.name
  # vpc_security_group_ids    = var.vpc_security_group_ids
  skip_final_snapshot       = true
  final_snapshot_identifier = var.final_snapshot_identifier
  publicly_accessible       = var.publicly_accessible

  # If you chose to use password manager:
  #   password = data.aws_secretsmanager_secret_version.db_password.secret_string
  password = var.db_password

  tags = {
    Environment = var.environment
  }
}