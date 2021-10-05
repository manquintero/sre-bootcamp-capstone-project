# LB
output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "The domain name of the load balancer"
}

# ECR
output "ecr_repository_worker_endpoint" {
  value = module.ecr.repository_url
}

# Data Store
# output "mysql_endpoint" {
#   value = module.data-store.endpoint
# }