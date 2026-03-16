variable "project_name" {
  description = "Short project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment: dev, staging, production"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name (e.g. example.com)"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name — used as the dynamic origin"
  type        = string
}

variable "s3_bucket_regional_domain" {
  description = "S3 bucket regional domain name — used as the static/media origin"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN — used in the bucket policy for OAC"
  type        = string
}
