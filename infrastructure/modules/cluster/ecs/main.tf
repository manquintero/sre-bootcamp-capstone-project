resource "aws_ecr_repository" "worker" {
  name = "worker"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "my-cluster"
}

resource "aws_ecs_task_definition" "task_definition" {
  family = "worker"
  # container_definitions = "${file("task-definitions/service.json")}"
  # container_definitions = data.template_file.task_definition_template.rendered
  container_definitions = <<EOF
[
  {
    "name": "nginx",
    "image": "nginx:1.13-alpine",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80
      }
    ],
    "memory": 128,
    "cpu": 100
  }
]
EOF
}

resource "aws_ecs_service" "worker" {
  name            = "worker"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 2
}