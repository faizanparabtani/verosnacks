output "cloudfront_domain" {
  description = "CloudFront distribution domain — point your DNS CNAME here"
  value       = module.cloudfront.cloudfront_domain_name
}

output "alb_dns_name" {
  description = "ALB DNS name (internal — CloudFront origin)"
  value       = module.alb.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.rds.db_host
  sensitive   = true
}

output "elasticache_endpoint" {
  description = "ElastiCache primary endpoint"
  value       = module.elasticache.cache_primary_endpoint
  sensitive   = true
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.ecs_cluster_name
}

output "s3_bucket_name" {
  description = "S3 static files bucket name"
  value       = module.s3.bucket_name
}

output "sqs_queue_url" {
  description = "Celery SQS queue URL"
  value       = module.sqs.queue_url
}
