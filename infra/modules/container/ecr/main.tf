data "aws_ecr_repository" "service" {
  name = var.repository_name
}