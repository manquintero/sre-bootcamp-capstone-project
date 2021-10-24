variable "environment" {
  description = "Infrastrucutre configuration"
  type        = string
  validation {
    condition     = contains(["Development", "Staging", "Production"], var.environment)
    error_message = "The environment valid values are: [Development, Staging, Production]."
  }
}

variable "container_tag" {
  description = "Hash for the container image"
  type        = string
}

variable "ecs_desired_count" {
  description = "Number of instances of the task definition to place and keep running"
  type        = number
}

variable "ecs_container_memory" {
  default = 64
  type    = number
}

variable "ecs_container_cpu" {
  default = 50
  type    = number
}

variable "asg_instance_type" {
  description = "Override the instance type in the Launch Template"
  type        = string
  default     = "t2.micro"
}

variable "asg_enable_ssh_in" {
  description = "If set to true, enable ssh port from Bastion to EC2"
  type        = bool
}

variable "asg_enable_autoscaling_schedule" {
  description = "If set to true, enable auto scaling"
  type        = bool
}