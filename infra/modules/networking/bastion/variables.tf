variable "vpc_id" {
  description = "VCP identifier."
  type        = string
}

variable "environment" {
  description = "Infrastrucutre configuration."
  type        = string
}

variable "subnet_id" {
  description = "VPC Subnet ID to launch in."
  type        = string
}

variable "internal_networks" {
  type        = list(string)
  description = "Internal network CIDR blocks."
}
