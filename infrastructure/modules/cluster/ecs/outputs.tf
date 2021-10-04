output "repository_url" {
  value = aws_ecr_repository.ecr.repository_url
}

output "cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}