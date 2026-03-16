variable "project_name" {
  description = "Short project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment: dev, staging, production"
  type        = string
}

variable "aws_region" {
  description = "AWS region (used in CloudWatch log configuration)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ecs_tasks_sg_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN for the Django service"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ECS task role ARN"
  type        = string
}

variable "django_image_uri" {
  description = "ECR image URI for the Django app"
  type        = string
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN for RDS credentials (JSON with host, dbname, username, password)"
  type        = string
}

variable "redis_url_secret_arn" {
  description = "Secrets Manager ARN for the Redis URL"
  type        = string
}

variable "django_secret_key_arn" {
  description = "Secrets Manager ARN for Django SECRET_KEY"
  type        = string
}

variable "sqs_queue_url" {
  description = "SQS queue URL passed to tasks as SQS_QUEUE_URL env var"
  type        = string
}
