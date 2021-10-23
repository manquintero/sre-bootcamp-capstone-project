variable "environment" {
  description = "Infrastrucutre configuration"
  type        = string
  validation {
    condition     = contains(["Development", "Staging", "Production"], var.environment)
    error_message = "The environmen valid values are: Development, Staging, Production"
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

variable "asg_min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
}

variable "asg_max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type        = number
}

variable "asg_instance_type" {
  description = "Override the instance type in the Launch Template"
  type        = string
  default     = "t2.micro"
}
