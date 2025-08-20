variable "region" {
  type = string
}

variable "db_password" {
  type = string
}

variable "create_db_instance_postgres" {
  type = bool
}

variable "create_db_instance_docdb" {
  type = bool
}

variable "subnet_id" {
  type = string
}


variable "create_backup" {
  type = bool
}

variable "email" {
  type = string
}