output "db_password_secret_arn" {
  value = aws_secretsmanager_secret.database_password_secret.arn
}