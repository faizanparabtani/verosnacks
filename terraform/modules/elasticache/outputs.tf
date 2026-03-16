output "cache_primary_endpoint" {
  description = "ElastiCache primary endpoint address"
  value       = aws_elasticache_replication_group.valkey.primary_endpoint_address
  sensitive   = true
}

output "cache_port" {
  description = "ElastiCache port"
  value       = aws_elasticache_replication_group.valkey.port
}

output "cache_connection_string" {
  description = "Full Redis connection string (redis://endpoint:6379/0)"
  value       = "redis://${aws_elasticache_replication_group.valkey.primary_endpoint_address}:6379/0"
  sensitive   = true
}
