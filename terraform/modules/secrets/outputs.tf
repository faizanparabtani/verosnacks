output "django_secret_key_arn" {
  description = "Secrets Manager ARN for the Django SECRET_KEY"
  value       = aws_secretsmanager_secret.django_secret_key.arn
}

output "rds_credentials_arn" {
  description = "Secrets Manager ARN for RDS credentials (version populated by rds module)"
  value       = aws_secretsmanager_secret.rds_credentials.arn
}

output "redis_url_arn" {
  description = "Secrets Manager ARN for the Redis URL (version populated by elasticache module)"
  value       = aws_secretsmanager_secret.redis_url.arn
}
