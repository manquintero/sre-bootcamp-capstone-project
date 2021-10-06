output "db_password_secret_arn" {
  value = aws_secretsmanager_secret.database_password_secret.arn
}

output "db_password" {
  value     = random_password.database_password.result
  sensitive = true
}