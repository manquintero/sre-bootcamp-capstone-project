# LoadBalancer
output "alb_dns_name" {
  value       = module.app.alb_dns_name
  description = "The domain name of the load balancer"
}

# Elastic Container Registry
output "ecr_repository_worker_endpoint" {
  value       = module.app.ecr_repository_worker_endpoint
  description = "The URL of the repository (in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName)"
}

# RDS
output "mysql_connection_parameters" {
  value       = module.app.mysql_connection_parameters
  description = "mysql connection string"
}

# Bastions
output "bastion_public_ip" {
  value = module.app.bastion_public_ip
}