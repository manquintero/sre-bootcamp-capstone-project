data "template_file" "task_definition_template" {
  template = file("${path.module}/templates/task_definition.json.tpl")
  vars = {
    "container_name"  = var.container_name
    "container_image" = var.container_image
    "container_port"  = var.container_port
    "host_port"       = var.host_port
  }
}

resource "aws_ecr_repository" "ecr" {
  name = var.repository
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.app_name}-cluster"
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = var.app_name
  container_definitions = data.template_file.task_definition_template.rendered
  tags = {
    Name = var.app_name
  }
}

resource "aws_ecs_service" "app" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = var.desired_count

  load_balancer {
    target_group_arn = var.aws_lb_target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}