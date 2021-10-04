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