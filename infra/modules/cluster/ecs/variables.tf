variable "environment" {
  description = "Infrastrucutre configuration"
  type        = string
}

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

variable "container_tag" {
  description = "Hash for the container image"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "The port number on the container that is bound to the user-specified or automatically assigned host port"
  type        = number
}

variable "container_memory" {
  default = 128
  type    = number
}

variable "container_cpu" {
  default = 100
  type    = number
}

variable "host_port" {
  description = "The port number on the container instance to reserve for your container"
  type        = number
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running."
  type        = number
}

variable "force_new_deployment" {
  description = "Enable to force a new task deployment of the service."
  type        = bool
  default     = true
}
variable "db_host" {
  description = "The hostname of the RDS instance"
  sensitive   = true
}

variable "db_username" {
  description = "The username of the RDS instance"
  sensitive   = true
}

variable "db_password_arn" {
  default     = ""
  description = "name or ARN of a secrets manager secret (arn:aws:secretsmanager:region:aws_account_id:secret:secret_name)"
  type        = string
}
