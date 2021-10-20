variable "vpc_id" {
  description = "VCP identifier."
  type        = string
}

variable "environment" {
  description = "Infrastrucutre configuration."
  type        = string
}

variable "internal_networks" {
  description = "Internal network CIDR blocks."
  type        = list(string)
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in."
  type        = list(string)
}
