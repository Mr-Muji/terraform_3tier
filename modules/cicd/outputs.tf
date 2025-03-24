output "repository_url" {
  description = "생성된 ECR 저장소 URL"
  value       = aws_ecr_repository.backend_repo.repository_url
}

output "repository_name" {
  description = "생성된 ECR 저장소 이름"
  value       = aws_ecr_repository.backend_repo.name
}

output "repository_arn" {
  description = "생성된 ECR 저장소 ARN"
  value       = aws_ecr_repository.backend_repo.arn
}

# 프론트엔드 저장소 출력값
output "frontend_repository_url" {
  description = "생성된 프론트엔드 ECR 저장소 URL"
  value       = aws_ecr_repository.frontend_repo.repository_url
}

output "frontend_repository_name" {
  description = "생성된 프론트엔드 ECR 저장소 이름"
  value       = aws_ecr_repository.frontend_repo.name
}

output "frontend_repository_arn" {
  description = "생성된 프론트엔드 ECR 저장소 ARN"
  value       = aws_ecr_repository.frontend_repo.arn
}