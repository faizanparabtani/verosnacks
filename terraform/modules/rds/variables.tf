variable "project_name" {
  description = "Short project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment: dev, staging, production"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "rds_sg_id" {
  description = "Security group ID for RDS"
  type        = string
}

variable "rds_monitoring_role_arn" {
  description = "IAM role ARN for RDS Enhanced Monitoring"
  type        = string
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "djangodb"
}

variable "db_username" {
  description = "Master database username"
  type        = string
  default     = "djangouser"
}

variable "rds_credentials_secret_arn" {
  description = "Secrets Manager ARN to populate with RDS credentials (created by secrets module)"
  type        = string
}
