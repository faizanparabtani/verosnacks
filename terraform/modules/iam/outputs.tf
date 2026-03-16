output "ecs_execution_role_arn" {
  description = "ECS task execution role ARN (used by ECS agent to pull images and fetch secrets)"
  value       = aws_iam_role.ecs_execution.arn
}

output "ecs_task_role_arn" {
  description = "ECS task role ARN (used by Django/Celery application code at runtime)"
  value       = aws_iam_role.ecs_task.arn
}

output "rds_monitoring_role_arn" {
  description = "RDS Enhanced Monitoring role ARN"
  value       = aws_iam_role.rds_monitoring.arn
}
