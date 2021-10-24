variable "vpc_id" {
  description = "VCP identifier"
  type        = string
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in."
  type        = list(string)
}

variable "target_group_arns" {
  description = "A set of aws_alb_target_group ARNs, for use with Application or Network Load Balancing"
  type        = list(string)
}

variable "cluster_name" {
  description = "Cluster Name"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 Instances in the ASG"
  type        = string
}

variable "host_port" {
  description = "The port number on the container instance to reserve for your container"
  type        = number
}

variable "alb_security_group_id" {
  description = "Security group id to allow access to/from"
  type        = string
}

variable "bastion_security_group_id" {
  description = "Security group id to allow access to/from"
  type        = string
}

variable "key_name" {
  description = "The key name that should be used for the instance."
  type        = string
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
}

variable "health_check_type" {
  description = "The type of health check to perform. Must be one of: EC2, ELB."
  type        = string
  default     = "EC2"
}

variable "launch_config_prefix" {
  description = "Creates a unique name beginning with the specified prefix"
  type        = string
}

variable "enable_ssh_in" {
  description = "If set to true, enable ssh port from Bastion to EC2"
  type        = bool
}

variable "enable_autoscaling_schedule" {
  description = "If set to true, enable auto scaling"
  type        = bool
}

variable "image_id" {
  description = "The EC2 image ID to launch."
  type        = string
}

variable "public_networks" {
  description = "Internal network CIDR blocks."
  type        = list(string)
}