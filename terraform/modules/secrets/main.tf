terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# ── Django secret key ─────────────────────────────────────────────────────────

resource "random_password" "django_secret_key" {
  length  = 64
  special = false
}

resource "aws_secretsmanager_secret" "django_secret_key" {
  name        = "${var.project_name}/${var.environment}/django-secret-key"
  description = "Django SECRET_KEY"

  tags = {
    Name = "${var.project_name}-${var.environment}-django-secret-key"
  }
}

resource "aws_secretsmanager_secret_version" "django_secret_key" {
  secret_id     = aws_secretsmanager_secret.django_secret_key.id
  secret_string = random_password.django_secret_key.result
}

# ── RDS credentials ───────────────────────────────────────────────────────────
# Secret resource only — the actual credentials version is created by the rds
# module after it generates the random password and provisions the instance.

resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "${var.project_name}/${var.environment}/rds"
  description = "RDS PostgreSQL credentials (host, port, dbname, username, password)"

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-credentials"
  }
}

# ── Redis URL ─────────────────────────────────────────────────────────────────
# Secret resource only — the actual URL version is created by the elasticache
# module after the cluster endpoint is known.

resource "aws_secretsmanager_secret" "redis_url" {
  name        = "${var.project_name}/${var.environment}/redis-url"
  description = "ElastiCache Valkey connection URL (redis://endpoint:6379/0)"

  tags = {
    Name = "${var.project_name}-${var.environment}-redis-url"
  }
}
