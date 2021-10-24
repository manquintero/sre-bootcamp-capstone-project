variable "project" {
  description = "Project Identifier"
  type        = string
}

variable "environment" {
  description = "Infrastrucutre configuration"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "alb_subnet_ids" {
  description = "A list of subnet IDs to attach to the LB"
  type        = list(string)
}

variable "bastion_internal_networks" {
  description = "Internal network CIDR blocks."
  type        = list(string)
}

variable "bastion_vpc_zone_identifier" {
  description = "A list of one or more availability zones for the group"
  type        = list(string)
}

variable "ecs_desired_count" {
  description = "Number of instances of the task definition to place and keep running"
  type        = number
}

variable "ecs_container_memory" {
  default = 128
  type    = number
}

variable "ecs_container_cpu" {
  default = 100
  type    = number
}

variable "ecs_container_tag" {
  description = "Hash for the container image"
  type        = string
}

variable "asg_vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in."
  type        = list(string)
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

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t2.micro"
}

variable "db_subnets" {
  description = "A list of VPC subnet ID"
  type        = list(string)
}

variable "db_internal_networks" {
  description = "Internal network CIDR blocks."
  type        = list(string)
}