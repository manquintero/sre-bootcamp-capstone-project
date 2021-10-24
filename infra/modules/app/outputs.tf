# LoadBalancer
output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "The domain name of the load balancer"
}

# Elastic Container Registry
output "ecr_repository_worker_endpoint" {
  value       = module.ecr.repository_url
  description = "The URL of the repository (in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName)"
}

# Data Store
output "mysql_connection_parameters" {
  value       = "mysql -u ${module.datastore.user} -h ${module.datastore.address} -p"
  description = "mysql connection string"
}

# Bastions
output "bastion_public_ip" {
  value = module.bastion.public_ip
}