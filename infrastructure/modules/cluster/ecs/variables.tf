variable "app_name" {
  description = "Name of the container to be run"
  type        = string
}

variable "aws_lb_target_group_arn" {
  description = "ARN of the Load Balancer target group to associate with the service"
  type        = string
}

variable "container_name" {
  description = "Name of the container to associate with the load balancer (as it appears in a container definition)"
  type        = string
}

variable "container_image" {
  description = "Name of the container image"
  type        = string
}

variable "container_port" {
  description = "The port number on the container that is bound to the user-specified or automatically assigned host port"
  type        = number
}

variable "host_port" {
  description = "The port number on the container instance to reserve for your container"
  type        = number
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running"
  type        = number
}