resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-cache-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-cache-subnet-group"
  }
}

resource "aws_elasticache_parameter_group" "valkey" {
  name   = "${var.project_name}-${var.environment}-valkey8"
  family = "valkey8"

  parameter {
    name  = "maxmemory-policy"
    value = "volatile-lru" # Evicts keys with a TTL first — protects sessions
  }

  parameter {
    name  = "timeout"
    value = "300" # Close idle connections after 5 minutes
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-valkey8-params"
  }
}

# Using replication_group even for a single node — easy to add a replica later
# by incrementing num_cache_clusters to 2 and setting automatic_failover_enabled = true
resource "aws_elasticache_replication_group" "valkey" {
  replication_group_id = "${var.project_name}-${var.environment}-cache"
  description          = "Valkey cache for ${var.project_name} ${var.environment}"

  node_type          = "cache.t3.micro"
  num_cache_clusters = 1   # Set to 2 for primary + replica in AZ-b
  port               = 6379

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [var.elasticache_sg_id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  automatic_failover_enabled = false # Set true when num_cache_clusters >= 2

  engine         = "valkey"
  engine_version = "8.0"

  parameter_group_name = aws_elasticache_parameter_group.valkey.name

  snapshot_retention_limit = 1
  snapshot_window          = "02:00-03:00"

  tags = {
    Name = "${var.project_name}-${var.environment}-valkey"
  }
}

# Populate the redis URL secret created by the secrets module
resource "aws_secretsmanager_secret_version" "redis_url" {
  secret_id     = var.redis_url_secret_arn
  secret_string = "redis://${aws_elasticache_replication_group.valkey.primary_endpoint_address}:6379/0"
}
