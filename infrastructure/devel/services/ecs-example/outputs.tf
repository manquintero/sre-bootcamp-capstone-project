output "mysql_endpoint" {
  value = module.data-store.endpoint
}

output "ecr_repository_worker_endpoint" {
  value = module.ecs.repository_url
}