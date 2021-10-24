resource "random_password" "database_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "database_password_secret" {
  name_prefix             = "${var.project}-${var.environment}-datastore-"
  description             = "Master password for the Database"
  recovery_window_in_days = 0

  tags = {
    "Environment" = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "database_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.database_password_secret.id
  secret_string = random_password.database_password.result
}
