resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-cluster"
  }
}

resource "aws_cloudwatch_log_group" "django" {
  name              = "/ecs/${var.project_name}/django"
  retention_in_days = 30

  tags = {
    Name = "/ecs/${var.project_name}/django"
  }
}

resource "aws_cloudwatch_log_group" "celery" {
  name              = "/ecs/${var.project_name}/celery"
  retention_in_days = 30

  tags = {
    Name = "/ecs/${var.project_name}/celery"
  }
}

# ── Task Definition: Django App ───────────────────────────────────────────────

resource "aws_ecs_task_definition" "django" {
  family                   = "${var.project_name}-django"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024" # 1 vCPU
  memory                   = "2048" # 2 GB
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name  = "django"
      image = var.django_image_uri

      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]

      # Non-secret config — safe to put in environment
      environment = [
        {
          name  = "DJANGO_SETTINGS_MODULE"
          value = "${var.project_name}.settings.production"
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "SQS_QUEUE_URL"
          value = var.sqs_queue_url
        }
      ]

      # Secrets — ECS pulls these from Secrets Manager at task start using the execution role.
      # JSON key extraction syntax: secretArn:jsonKey::
      secrets = [
        {
          name      = "DB_HOST"
          valueFrom = "${var.db_secret_arn}:host::"
        },
        {
          name      = "DB_NAME"
          valueFrom = "${var.db_secret_arn}:dbname::"
        },
        {
          name      = "DB_USER"
          valueFrom = "${var.db_secret_arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${var.db_secret_arn}:password::"
        },
        {
          name      = "REDIS_URL"
          valueFrom = var.redis_url_secret_arn
        },
        {
          name      = "DJANGO_SECRET_KEY"
          valueFrom = var.django_secret_key_arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}/django"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8000/health/ || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-django-task"
  }
}

# ── Task Definition: Celery Worker ────────────────────────────────────────────

resource "aws_ecs_task_definition" "celery" {
  family                   = "${var.project_name}-celery"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"  # 0.5 vCPU
  memory                   = "1024" # 1 GB
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name    = "celery"
      image   = var.django_image_uri
      command = ["celery", "-A", var.project_name, "worker", "--loglevel=info"]

      environment = [
        {
          name  = "DJANGO_SETTINGS_MODULE"
          value = "${var.project_name}.settings.production"
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "SQS_QUEUE_URL"
          value = var.sqs_queue_url
        }
      ]

      secrets = [
        {
          name      = "DB_HOST"
          valueFrom = "${var.db_secret_arn}:host::"
        },
        {
          name      = "DB_NAME"
          valueFrom = "${var.db_secret_arn}:dbname::"
        },
        {
          name      = "DB_USER"
          valueFrom = "${var.db_secret_arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${var.db_secret_arn}:password::"
        },
        {
          name      = "REDIS_URL"
          valueFrom = var.redis_url_secret_arn
        },
        {
          name      = "DJANGO_SECRET_KEY"
          valueFrom = var.django_secret_key_arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}/celery"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-celery-task"
  }
}

# ── ECS Service: Django ───────────────────────────────────────────────────────

resource "aws_ecs_service" "django" {
  name             = "${var.project_name}-${var.environment}-django"
  cluster          = aws_ecs_cluster.main.id
  task_definition  = aws_ecs_task_definition.django.arn
  desired_count    = 2
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_tasks_sg_id]
    assign_public_ip = false # Tasks are in private subnets — they reach internet via NAT GW
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "django"
    container_port   = 8000
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60

  # Fargate automatically distributes tasks across the AZs of the provided subnets.
  # No explicit placement constraints needed — providing both private subnet IDs is sufficient.

  tags = {
    Name = "${var.project_name}-${var.environment}-django-service"
  }
}

# ── ECS Service: Celery Worker ────────────────────────────────────────────────

resource "aws_ecs_service" "celery" {
  name             = "${var.project_name}-${var.environment}-celery"
  cluster          = aws_ecs_cluster.main.id
  task_definition  = aws_ecs_task_definition.celery.arn
  desired_count    = 2
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_tasks_sg_id]
    assign_public_ip = false
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  tags = {
    Name = "${var.project_name}-${var.environment}-celery-service"
  }
}

# ── Auto Scaling: Django Service ──────────────────────────────────────────────

resource "aws_appautoscaling_target" "django" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.django.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "django_cpu" {
  name               = "${var.project_name}-${var.environment}-django-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.django.resource_id
  scalable_dimension = aws_appautoscaling_target.django.scalable_dimension
  service_namespace  = aws_appautoscaling_target.django.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 60.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "django_memory" {
  name               = "${var.project_name}-${var.environment}-django-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.django.resource_id
  scalable_dimension = aws_appautoscaling_target.django.scalable_dimension
  service_namespace  = aws_appautoscaling_target.django.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
