output "endpoint" {
  value       = aws_db_instance.mysql.endpoint
  description = "The connection endpoint in address:port format"
}

output "address" {
  value       = aws_db_instance.mysql.address
  description = "The hostname of the RDS instance"
}

output "port" {
  value       = aws_db_instance.mysql.port
  description = "The database port"
}