variable "project_name" {
  description = "Short project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment: dev, staging, production"
  type        = string
}

variable "aws_region" {
  description = "AWS region (used for VPC endpoint service names)"
  type        = string
}
