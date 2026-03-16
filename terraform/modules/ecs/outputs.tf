output "ecs_cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "django_service_name" {
  description = "ECS Django service name"
  value       = aws_ecs_service.django.name
}

output "celery_service_name" {
  description = "ECS Celery service name"
  value       = aws_ecs_service.celery.name
}
