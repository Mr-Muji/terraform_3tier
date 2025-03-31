#=======================================================
# 00단계: 출력값 설정
#=======================================================
# 이 파일은 다음 출력값을 정의합니다:
# 1. ECR 저장소 정보 (URL, 이름)
# 2. S3 버킷 정보 (이름, ARN, 도메인)
# 3. CloudFront 배포 정보 (ID, ARN, 도메인)
#=======================================================

#---------------------------------------
# 1. ECR 저장소 출력값
#---------------------------------------

# 프론트엔드 ECR 저장소 URL
output "frontend_ecr_url" {
  description = "프론트엔드 ECR 저장소 URL"
  value       = local.create_frontend_ecr ? module.frontend_ecr[0].repository_url : null  # 조건부 출력
}

# 프론트엔드 ECR 저장소 이름
output "frontend_ecr_name" {
  description = "프론트엔드 ECR 저장소 이름"
  value       = local.create_frontend_ecr ? module.frontend_ecr[0].repository_name : null  # 조건부 출력
}

# 백엔드 ECR 저장소 URL
output "backend_ecr_url" {
  description = "백엔드 ECR 저장소 URL"
  value       = local.create_backend_ecr ? module.backend_ecr[0].repository_url : null  # 조건부 출력
}

# 백엔드 ECR 저장소 이름
output "backend_ecr_name" {
  description = "백엔드 ECR 저장소 이름"
  value       = local.create_backend_ecr ? module.backend_ecr[0].repository_name : null  # 조건부 출력
}

#---------------------------------------
# 2. S3 버킷 출력값
#---------------------------------------

# S3 버킷 이름
output "frontend_s3_bucket_name" {
  description = "프론트엔드 S3 버킷 이름"
  value       = local.create_frontend_s3 ? module.frontend[0].s3_bucket_name : ""  # 조건부 출력
}

# S3 버킷 ARN
output "frontend_s3_bucket_arn" {
  description = "프론트엔드 S3 버킷 ARN"
  value       = local.create_frontend_s3 ? module.frontend[0].s3_bucket_arn : ""  # 조건부 출력
}

# S3 버킷 도메인 이름
output "frontend_s3_bucket_domain_name" {
  description = "프론트엔드 S3 버킷 도메인 이름"
  value       = local.create_frontend_s3 ? module.frontend[0].s3_bucket_domain_name : ""  # 조건부 출력
}

#---------------------------------------
# 3. CloudFront 출력값
#---------------------------------------

# CloudFront 배포 ID
output "cloudfront_distribution_id" {
  description = "CloudFront 배포 ID"
  value       = local.create_frontend_s3 ? module.frontend[0].cloudfront_distribution_id : ""  # 조건부 출력
}

# CloudFront 배포 ARN
output "cloudfront_distribution_arn" {
  description = "CloudFront 배포 ARN"
  value       = local.create_frontend_s3 ? module.frontend[0].cloudfront_distribution_arn : ""  # 조건부 출력
}

# CloudFront 도메인 이름
output "cloudfront_domain_name" {
  description = "CloudFront 도메인 이름"
  value       = local.create_frontend_s3 ? module.frontend[0].cloudfront_domain_name : ""  # 조건부 출력
}

# CloudFront 호스팅 영역 ID
output "cloudfront_hosted_zone_id" {
  description = "CloudFront 호스팅 영역 ID"
  value       = local.create_frontend_s3 ? module.frontend[0].cloudfront_hosted_zone_id : ""  # 조건부 출력
}