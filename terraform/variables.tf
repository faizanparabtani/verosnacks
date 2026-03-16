variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ca-central-1"
}

variable "project_name" {
  description = "Short project name used in resource naming"
  type        = string
  default     = "django-app"
}

variable "environment" {
  description = "Deployment environment: dev, staging, production"
  type        = string
  default     = "production"
}

variable "domain_name" {
  description = "Primary domain name (e.g. example.com)"
  type        = string
}

variable "django_image_uri" {
  description = "ECR image URI for the Django app (e.g. 123456789.dkr.ecr.ca-central-1.amazonaws.com/django-app:latest)"
  type        = string
}
