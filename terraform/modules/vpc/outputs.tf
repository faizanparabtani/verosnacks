output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs [az-a, az-b]"
  value       = [aws_subnet.public_az_a.id, aws_subnet.public_az_b.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs [az-a, az-b]"
  value       = [aws_subnet.private_az_a.id, aws_subnet.private_az_b.id]
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}
