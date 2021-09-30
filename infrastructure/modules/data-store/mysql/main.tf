resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-up-and-running"
  engine            = "mysql"
  allocated_storage = var.db_allocated_storage
  instance_class    = var.db_instance_class
  name              = "${var.db_instance_name}-mysql"
  username          = var.db_username
  password          = var.db_password
}