#---------------------------------------
# 00단계: 출력값 설정
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

# S3 버킷 출력
output "frontend_s3_bucket_name" {
  description = "프론트엔드 S3 버킷 이름"
  value       = local.create_frontend_s3 ? aws_s3_bucket.frontend[0].bucket : ""
}

output "frontend_s3_bucket_arn" {
  description = "프론트엔드 S3 버킷 ARN"
  value       = local.create_frontend_s3 ? aws_s3_bucket.frontend[0].arn : ""
}

output "frontend_s3_bucket_domain_name" {
  description = "프론트엔드 S3 버킷 도메인 이름"
  value       = local.create_frontend_s3 ? aws_s3_bucket.frontend[0].bucket_regional_domain_name : ""
}

# CloudFront 출력
output "cloudfront_distribution_id" {
  description = "CloudFront 배포 ID"
  value       = local.create_cloudfront ? aws_cloudfront_distribution.frontend[0].id : ""
}

output "cloudfront_distribution_arn" {
  description = "CloudFront 배포 ARN"
  value       = local.create_cloudfront ? aws_cloudfront_distribution.frontend[0].arn : ""
}

output "cloudfront_domain_name" {
  description = "CloudFront 도메인 이름"
  value       = local.create_cloudfront ? aws_cloudfront_distribution.frontend[0].domain_name : ""
}

output "cloudfront_hosted_zone_id" {
  description = "CloudFront 호스팅 영역 ID"
  value       = local.create_cloudfront ? aws_cloudfront_distribution.frontend[0].hosted_zone_id : ""
}