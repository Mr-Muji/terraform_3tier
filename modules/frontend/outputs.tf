# modules/frontend/outputs.tf

#---------------------------------------
# 프론트엔드 모듈 출력 값 정의
# 이 파일은 프론트엔드 모듈에서 외부로 노출할 값들을 정의합니다.
# 다른 모듈이나 루트 모듈에서 이 값들을 참조할 수 있습니다.
#---------------------------------------

#---------------------------------------
# S3 버킷 관련 출력 값
#---------------------------------------

# 프론트엔드 S3 버킷 이름 출력
# 정적 웹사이트 호스팅에 사용되는 S3 버킷의 이름 반환
# CI/CD 파이프라인에서 파일 업로드 시 사용할 수 있음
output "s3_bucket_name" {
  description = "프론트엔드 S3 버킷 이름"
  value       = aws_s3_bucket.frontend.bucket  # 생성된 S3 버킷의 이름 참조
}

# 프론트엔드 S3 버킷 ARN 출력
# Amazon 리소스 식별자로, IAM 정책 등에서 버킷 참조 시 사용
# 다른 AWS 서비스와의 통합에 필요한 ARN 정보 제공
output "s3_bucket_arn" {
  description = "프론트엔드 S3 버킷 ARN"
  value       = aws_s3_bucket.frontend.arn  # S3 버킷의 Amazon 리소스 이름(ARN) 참조
}

#---------------------------------------
# CloudFront 관련 출력 값
#---------------------------------------

# 프론트엔드 CloudFront 도메인 출력
# 사용자가 애플리케이션에 접근할 수 있는 CloudFront 도메인 주소 반환
# 사용자 접속 URL로 사용되며, 커스텀 도메인 설정 전까지 기본 URL로 활용
output "cloudfront_domain_name" {
  description = "프론트엔드 CloudFront 도메인"
  value       = aws_cloudfront_distribution.frontend.domain_name  # CloudFront에서 생성된 도메인 이름 참조
}

# 프론트엔드 CloudFront 배포 ID 출력
# CloudFront 배포의 고유 식별자로, 캐시 무효화 등 관리 작업에 사용
# CI/CD 파이프라인에서 배포 후 캐시 무효화가 필요할 때 사용
output "cloudfront_distribution_id" {
  description = "프론트엔드 CloudFront 배포 ID"
  value       = aws_cloudfront_distribution.frontend.id  # CloudFront 배포의 ID 참조
}