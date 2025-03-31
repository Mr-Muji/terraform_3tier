#---------------------------------------
# 프론트엔드 모듈 출력값
#---------------------------------------

# 1. S3 버킷 출력값
output "s3_bucket_name" {
  description = "프론트엔드 S3 버킷 이름"
  value       = aws_s3_bucket.frontend_bucket.bucket
}

output "s3_bucket_arn" {
  description = "프론트엔드 S3 버킷 ARN"
  value       = aws_s3_bucket.frontend_bucket.arn
}

output "s3_bucket_domain_name" {
  description = "프론트엔드 S3 버킷 도메인 이름"
  value       = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
}

# 2. CloudFront 출력값
output "cloudfront_distribution_id" {
  description = "CloudFront 배포 ID"
  value       = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_distribution_arn" {
  description = "CloudFront 배포 ARN"
  value       = aws_cloudfront_distribution.frontend.arn
}

output "cloudfront_domain_name" {
  description = "CloudFront 도메인 이름"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "CloudFront 호스팅 영역 ID"
  value       = aws_cloudfront_distribution.frontend.hosted_zone_id
}

# 3. Route53 레코드 출력값
output "route53_domain_record" {
  description = "메인 도메인 Route53 레코드"
  value       = var.create_route53_records ? aws_route53_record.frontend[0].fqdn : null
}

output "route53_www_record" {
  description = "www 서브도메인 Route53 레코드"
  value       = var.create_route53_records ? aws_route53_record.www[0].fqdn : null
}
