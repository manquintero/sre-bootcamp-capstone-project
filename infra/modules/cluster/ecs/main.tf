data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "task_permissions" {
  statement {
    effect = "Allow"

    resources = ["*"]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }
}

data "aws_iam_policy_document" "read_repository_credentials" {
  statement {
    effect = "Allow"

    resources = [
      var.db_password_arn,
    ]

    actions = [
      "secretsmanager:GetSecretValue",
    ]
  }
}

#####
# Execution IAM Role
#####
resource "aws_iam_role" "execution" {
  name               = "${var.app_name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attach" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "read_repository_credentials" {
  name   = "${var.app_name}-read-repository-credentials"
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.read_repository_credentials.json
}

#####
# IAM - Task role, basic. Append policies to this role for S3, DynamoDB etc.
#####
resource "aws_iam_role" "task" {
  name               = "${var.app_name}-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy" "log_agent" {
  name   = "${var.app_name}-log-permissions"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task_permissions.json
}

# Task definition
data "template_file" "task_definition_template" {
  template = file("${path.module}/templates/task_definition.json.tpl")
  vars = {
    "container_name"  = var.container_name
    "container_image" = var.container_image
    "container_tag"   = var.container_tag
    "container_port"  = var.container_port
    "host_port"       = var.host_port
    "db_host"         = var.db_host
    "db_username"     = var.db_username
    "db_password_arn" = var.db_password_arn
    "memory"          = var.container_memory
    "cpu"             = var.container_cpu
    "environment"     = var.environment
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = lower("${var.app_name}-cluster-${var.environment}")

  tags = {
    Environment = var.environment
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = var.app_name
  container_definitions = data.template_file.task_definition_template.rendered
  # Roles
  execution_role_arn = aws_iam_role.execution.arn
  task_role_arn      = aws_iam_role.task.arn

  tags = {
    Name = var.app_name
  }
}

resource "aws_ecs_service" "app" {
  name                 = var.app_name
  cluster              = aws_ecs_cluster.ecs_cluster.id
  task_definition      = aws_ecs_task_definition.task_definition.arn
  desired_count        = var.desired_count
  force_new_deployment = true

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  load_balancer {
    target_group_arn = var.aws_lb_target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Environment = var.environment
  }
}