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

variable "create_jump_host" {
  type = bool
}

variable "create_event_processor_lambda" {
  type = bool
}

variable "create_app1" {
  type = bool
}

variable "create_alb" {
  type = bool
}
variable "create_custom_vpc" {
  type = bool

}

variable "use_default_vpc" {
  type = bool
}

variable "create_vpn_server" {
  type = bool
}

variable "create_sns_topics" {
  type        = bool
  description = "Whether to create SNS topics for notifications"
  default     = false
}

variable "create_cloudwatch_alarms" {
  type        = bool
  description = "Whether to create CloudWatch alarms"
  default     = false
}

variable "enable_cloudtrail" {
  type        = bool
  description = "Whether to enable CloudTrail logging"
  default     = true
}

variable "create_dynamodb" {
  type        = bool
  description = "Whether to create DynamoDB table"
  default     = false
}

variable "create_ecs_cluster" {
  type        = bool
  description = "Whether to create ECS cluster"
  default     = false
}