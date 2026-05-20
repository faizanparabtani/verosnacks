variable "project_name" {
  description = "Short project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment: dev, staging, production"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name (used in CORS allowed origins)"
  type        = string
}
