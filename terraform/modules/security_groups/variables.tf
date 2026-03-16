variable "vpc_id" {
  description = "VPC ID to create security groups in"
  type        = string
}

variable "project_name" {
  description = "Short project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment: dev, staging, production"
  type        = string
}
