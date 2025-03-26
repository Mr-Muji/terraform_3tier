#-----------------------------------------
# ECR 모듈 출력
#-----------------------------------------

output "repository_url" {
  description = "ECR 저장소 URL"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_name" {
  description = "ECR 저장소 이름"
  value       = aws_ecr_repository.this.name
}

output "repository_arn" {
  description = "ECR 저장소 ARN"
  value       = aws_ecr_repository.this.arn
}

output "registry_id" {
  description = "ECR 레지스트리 ID"
  value       = aws_ecr_repository.this.registry_id
} 