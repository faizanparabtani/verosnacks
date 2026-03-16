# Dead-letter queue — receives tasks after maxReceiveCount failed delivery attempts
resource "aws_sqs_queue" "dlq" {
  name                      = "${var.project_name}-${var.environment}-celery-dlq"
  message_retention_seconds = 1209600 # 14 days
  kms_master_key_id         = "alias/aws/sqs"

  tags = {
    Name = "${var.project_name}-${var.environment}-celery-dlq"
  }
}

resource "aws_sqs_queue" "celery" {
  name = "${var.project_name}-${var.environment}-celery"

  # Must be >= your longest Celery task execution time
  visibility_timeout_seconds = 300

  message_retention_seconds = 86400 # 1 day
  receive_wait_time_seconds = 20    # Long polling — reduces empty API calls and costs

  kms_master_key_id = "alias/aws/sqs"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3 # Retry 3 times before moving to DLQ
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-celery"
  }
}
