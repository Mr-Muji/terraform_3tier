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

# ArgoCD 관련 출력
output "argocd_namespace" {
  description = "ArgoCD가 설치된 네임스페이스"
  value       = var.install_argocd ? kubernetes_namespace.argocd[0].metadata[0].name : ""
}

output "argocd_server_service" {
  description = "ArgoCD 서버 서비스 이름"
  value       = var.install_argocd ? "argocd-server" : ""
}

output "frontend_namespace" {
  description = "프론트엔드 애플리케이션이 배포된 네임스페이스"
  value       = var.install_argocd ? kubernetes_namespace.frontend[0].metadata[0].name : ""
}
