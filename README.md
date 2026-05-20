# Vero Snacks

An E-Commerce platform for healthy snacks startup. with async task processing, containerized development, and AWS infrastructure provisioned via Terraform.

[![Python](https://img.shields.io/badge/python-3.13-blue.svg)](https://python.org)
[![Django](https://img.shields.io/badge/django-6.0-green.svg)](https://djangoproject.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/docker-compose-blue.svg)](compose.yaml)

## Architecture

![System architecture: Django web service and Celery workers running on AWS ECS Fargate, backed by RDS PostgreSQL and ElastiCache Redis, with CloudFront CDN, ALB, S3 for static/media, and SQS for async messaging](https://res.cloudinary.com/dklhalalp/image/upload/v1773640398/VeroSnacks.drawio_kftj7f.png)

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Python 3.13, Django 6.0 |
| Frontend | HTML5, Tailwind CSS v4, DaisyUI |
| Database | PostgreSQL 16 |
| Cache & Broker | Redis 7 |
| Task Queue | Celery 5 |
| Payments | Stripe |
| Media | Cloudinary |
| Package Manager | uv |
| Containers | Docker, Docker Compose |
| Infrastructure Provisioned | AWS via Terraform (ECS, RDS, ElastiCache, ALB, CloudFront, S3, Secrets Manager) |
| Current Infrastructure | Railway |

---

## Quickstart

Copy `.env.example` to `.env` — only `SECRET_KEY` and `POSTGRES_PASSWORD` are required to run locally.

```bash
git clone <repository-url>
cd verosnacks
cp .env.example .env
docker compose up --build
```

App available at `http://localhost:8000`. Migrations run automatically on startup.

---

## Infrastructure

Production infrastructure is defined in [`terraform/`](terraform/) and targets AWS. See [`terraform.tfvars.example`](terraform/terraform.tfvars.example) for required inputs.

---

## Troubleshooting

**Exits with a variable error** — `SECRET_KEY` and `POSTGRES_PASSWORD` must be set in `.env`.

**400 Bad Request / DisallowedHost** — add your hostname to `ALLOWED_HOSTS` in `.env`.

**Database refused on first boot** — PostgreSQL may not be ready yet; re-run `docker compose up`.

---

## License

[MIT](LICENSE)
