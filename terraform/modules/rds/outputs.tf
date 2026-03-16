output "db_host" {
  description = "RDS instance endpoint address"
  value       = aws_db_instance.postgres.address
  sensitive   = true
}

output "db_port" {
  description = "RDS instance port"
  value       = aws_db_instance.postgres.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.postgres.db_name
}

output "db_secret_arn" {
  description = "Secrets Manager ARN containing RDS credentials (used by ECS task secrets injection)"
  value       = var.rds_credentials_secret_arn
}
