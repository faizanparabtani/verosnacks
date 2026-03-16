variable "project_name" {
  description = "Short project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment: dev, staging, production"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the ElastiCache subnet group"
  type        = list(string)
}

variable "elasticache_sg_id" {
  description = "Security group ID for ElastiCache"
  type        = string
}

variable "redis_url_secret_arn" {
  description = "Secrets Manager ARN to populate with the Redis URL (created by secrets module)"
  type        = string
}
