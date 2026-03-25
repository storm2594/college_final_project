output "primary_alb_dns" {
  value = aws_lb.primary.dns_name
}

output "secondary_alb_dns" {
  value = aws_lb.secondary.dns_name
}



output "ecr_repository_frontend" {
  value = aws_ecr_repository.frontend.repository_url
}

output "ecr_repository_backend" {
  value = aws_ecr_repository.backend.repository_url
}
