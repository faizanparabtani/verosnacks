terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.40"
      configuration_aliases = [aws.us_east_1]
    }
  }
}

# Origin Access Control for S3 — replaces the legacy OAI pattern
resource "aws_cloudfront_origin_access_control" "s3" {
  name                              = "${var.project_name}-${var.environment}-s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ACM certificate MUST be in us-east-1 for CloudFront
resource "aws_acm_certificate" "cloudfront" {
  provider = aws.us_east_1

  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-cloudfront-cert"
  }
}

resource "aws_acm_certificate_validation" "cloudfront" {
  provider = aws.us_east_1

  certificate_arn         = aws_acm_certificate.cloudfront.arn
  validation_record_fqdns = [for record in aws_acm_certificate.cloudfront.domain_validation_options : record.resource_record_name]
}

resource "aws_cloudfront_distribution" "main" {
  enabled    = true
  aliases    = [var.domain_name, "www.${var.domain_name}"]
  price_class = "PriceClass_100" # US, Canada, Europe — cheapest class that covers Canada
  http_version = "http2and3"

  # Origin 1 — ALB (all dynamic Django traffic)
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "alb"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  # Origin 2 — S3 (static and media files via OAC)
  origin {
    domain_name              = var.s3_bucket_regional_domain
    origin_id                = "s3-static"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id

    s3_origin_config {
      origin_access_identity = "" # Required placeholder when using OAC instead of OAI
    }
  }

  # Default cache behavior → ALB origin (all Django dynamic traffic)
  default_cache_behavior {
    target_origin_id       = "alb"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    # CachingDisabled managed policy — no caching for dynamic content
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"

    # AllViewer managed policy — forwards all headers, cookies, query strings to origin
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
  }

  # /static/* → S3 origin with caching enabled
  ordered_cache_behavior {
    path_pattern           = "/static/*"
    target_origin_id       = "s3-static"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    # CachingOptimized managed policy — long TTLs, good for static assets
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  # /media/* → S3 origin with caching enabled
  ordered_cache_behavior {
    path_pattern           = "/media/*"
    target_origin_id       = "s3-static"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    # CachingOptimized managed policy
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 60
  }

  custom_error_response {
    error_code            = 500
    response_code         = 500
    response_page_path    = "/500.html"
    error_caching_min_ttl = 0
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cloudfront.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      # To restrict to Canada only, use:
      # restriction_type = "whitelist"
      # locations        = ["CA"]
    }
  }

  depends_on = [aws_acm_certificate_validation.cloudfront]

  tags = {
    Name = "${var.project_name}-${var.environment}-cloudfront"
  }
}
