variable "vpc_id" {
  description = "VCP identifier"
  type        = string
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in."
  type        = list(string)
}