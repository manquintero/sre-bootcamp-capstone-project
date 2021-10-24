output "cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

output "task_definition_revision" {
  value = "${aws_ecs_task_definition.task_definition.family}-${aws_ecs_task_definition.task_definition.revision}"
}