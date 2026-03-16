output "queue_url" {
  description = "Celery SQS queue URL (passed to ECS task as SQS_QUEUE_URL env var)"
  value       = aws_sqs_queue.celery.url
}

output "queue_arn" {
  description = "Celery SQS queue ARN (used in IAM policy)"
  value       = aws_sqs_queue.celery.arn
}

output "dlq_url" {
  description = "Dead-letter queue URL"
  value       = aws_sqs_queue.dlq.url
}

output "dlq_arn" {
  description = "Dead-letter queue ARN"
  value       = aws_sqs_queue.dlq.arn
}
