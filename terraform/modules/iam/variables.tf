variable "project_name" {
  description = "Short project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment: dev, staging, production"
  type        = string
}

variable "aws_region" {
  description = "AWS region (used in Secrets Manager ARN patterns)"
  type        = string
}

variable "sqs_queue_arn" {
  description = "SQS queue ARN for task role SQS policy"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN for task role S3 policy"
  type        = string
}

variable "django_secret_key_arn" {
  description = "Secrets Manager ARN for Django secret key"
  type        = string
}

variable "rds_credentials_arn" {
  description = "Secrets Manager ARN for RDS credentials"
  type        = string
}

variable "redis_url_arn" {
  description = "Secrets Manager ARN for Redis URL"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN for execution role image pull policy. Update with your actual ECR repo ARN."
  type        = string
  default     = "*" # Replace with specific ARN: arn:aws:ecr:ca-central-1:ACCOUNT:repository/REPO
}
