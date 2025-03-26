#---------------------------------------
# 00단계: 출력값 - ECR 저장소 정보
#---------------------------------------

# ECR 저장소 출력
output "frontend_ecr_url" {
  description = "프론트엔드 ECR 저장소 URL"
  value       = local.create_frontend_ecr ? module.frontend_ecr[0].repository_url : null
}

output "frontend_ecr_name" {
  description = "프론트엔드 ECR 저장소 이름"
  value       = local.create_frontend_ecr ? module.frontend_ecr[0].repository_name : null
}

output "backend_ecr_url" {
  description = "백엔드 ECR 저장소 URL"
  value       = local.create_backend_ecr ? module.backend_ecr[0].repository_url : null
}

output "backend_ecr_name" {
  description = "백엔드 ECR 저장소 이름"
  value       = local.create_backend_ecr ? module.backend_ecr[0].repository_name : null
}