output "cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

output "cluster_id" {
  description = "ARN that identifies the cluster."
  value       = aws_ecs_cluster.ecs_cluster.id
}

output "task_definition_revision" {
  value = "${aws_ecs_task_definition.task_definition.family}-${aws_ecs_task_definition.task_definition.revision}"
}