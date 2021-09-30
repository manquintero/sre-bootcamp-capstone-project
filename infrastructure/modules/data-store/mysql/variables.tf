variable "db_instance_name" {
  description = "Name for the Database"
  type        = string
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}

variable "db_allocated_storage" {
  description = "The allocated storage in gibibytes"
  type        = number
  default     = 10
}

variable "db_username" {
  description = "The username for the database"
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
}