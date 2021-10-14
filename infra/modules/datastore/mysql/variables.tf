variable "vpc_id" {
  description = "VCP identifier"
  type        = string
}

variable "identifier_prefix" {
  description = "Creates a unique identifier beginning with the specified prefix"
  type        = string
}

variable "db_subnets" {
  description = "A list of VPC subnet ID"
  type        = list(string)
}

variable "final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB instance is deleted."
  type        = string
}

variable "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible"
  type        = bool
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}

variable "db_username" {
  description = "The username for the database"
  type        = string
}

variable "db_password_secret_id" {
  description = "Specifies the secret containing the version that you want to retrieve. You can specify either the Amazon Resource Name (ARN) or the friendly name of the secret"
  type        = string
}

variable "environment" {
  description = "Categorize the environment in a Tag"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "Security group IDs to associate with"
  type        = string
}