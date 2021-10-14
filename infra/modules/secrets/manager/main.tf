resource "random_password" "database_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "database_password_secret" {
  name        = "/${var.environment}/datastore/master/${var.project}"
  description = "Master password for the Database"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "Environment" = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "database_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.database_password_secret.id
  secret_string = random_password.database_password.result
}
