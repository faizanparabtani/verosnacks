module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
}

module "security_groups" {
  source       = "./modules/security_groups"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  environment  = var.environment
}

module "sqs" {
  source       = "./modules/sqs"
  project_name = var.project_name
  environment  = var.environment
}

# secrets module creates the secret *resources* (names/ARNs).
# The actual secret values are populated by rds and elasticache modules.
module "secrets" {
  source       = "./modules/secrets"
  project_name = var.project_name
  environment  = var.environment
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  sqs_queue_arn         = module.sqs.queue_arn
  s3_bucket_arn         = module.s3.bucket_arn
  django_secret_key_arn = module.secrets.django_secret_key_arn
  rds_credentials_arn   = module.secrets.rds_credentials_arn
  redis_url_arn         = module.secrets.redis_url_arn

  # Replace with your actual ECR repository ARN:
  # ecr_repository_arn = "arn:aws:ecr:ca-central-1:123456789012:repository/myapp"
}

module "rds" {
  source       = "./modules/rds"
  project_name = var.project_name
  environment  = var.environment

  private_subnet_ids         = module.vpc.private_subnet_ids
  rds_sg_id                  = module.security_groups.rds_sg_id
  rds_monitoring_role_arn    = module.iam.rds_monitoring_role_arn
  db_name                    = "djangodb"
  db_username                = "djangouser"
  rds_credentials_secret_arn = module.secrets.rds_credentials_arn
}

module "elasticache" {
  source       = "./modules/elasticache"
  project_name = var.project_name
  environment  = var.environment

  private_subnet_ids   = module.vpc.private_subnet_ids
  elasticache_sg_id    = module.security_groups.elasticache_sg_id
  redis_url_secret_arn = module.secrets.redis_url_arn
}

module "alb" {
  source       = "./modules/alb"
  project_name = var.project_name
  environment  = var.environment

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security_groups.alb_sg_id
  domain_name       = var.domain_name
}

# cloudfront must run before s3 so its distribution ARN can be passed to the s3 bucket policy.
module "cloudfront" {
  source       = "./modules/cloudfront"
  project_name = var.project_name
  environment  = var.environment

  domain_name               = var.domain_name
  alb_dns_name              = module.alb.alb_dns_name
  s3_bucket_regional_domain = module.s3.bucket_regional_domain_name
  s3_bucket_arn             = module.s3.bucket_arn

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}

module "s3" {
  source       = "./modules/s3"
  project_name = var.project_name
  environment  = var.environment

  domain_name                 = var.domain_name
  cloudfront_distribution_arn = module.cloudfront.cloudfront_distribution_arn
}

module "ecs" {
  source       = "./modules/ecs"
  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_tasks_sg_id    = module.security_groups.ecs_tasks_sg_id
  target_group_arn   = module.alb.target_group_arn

  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  ecs_task_role_arn      = module.iam.ecs_task_role_arn

  django_image_uri      = var.django_image_uri
  db_secret_arn         = module.rds.db_secret_arn
  redis_url_secret_arn  = module.secrets.redis_url_arn
  django_secret_key_arn = module.secrets.django_secret_key_arn
  sqs_queue_url         = module.sqs.queue_url

  # Ensure RDS and ElastiCache are fully provisioned (including secret versions)
  # before ECS task definitions are created
  depends_on = [module.rds, module.elasticache]
}
