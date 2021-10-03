variable "vpc_id" {
  description = "VCP identifier"
  type        = string
}

variable "subnet_ids" {
  description = "the subnet IDs to deploy to"
  type        = list(string)
}