output "alb_dns_name" {
  description = "ALB DNS name (used as CloudFront origin)"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID (for Route53 alias records)"
  value       = aws_lb.main.zone_id
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "Django target group ARN (passed to ECS service)"
  value       = aws_lb_target_group.django.arn
}
