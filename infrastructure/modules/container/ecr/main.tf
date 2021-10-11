resource "aws_ecr_repository" "ecr" {
  name = var.repository

  # lifecycle {
  #   prevent_destroy = true
  # }
}