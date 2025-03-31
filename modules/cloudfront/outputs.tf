output "distribution_id" {
  description = "CloudFront 배포 ID"
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "distribution_arn" {
  description = "CloudFront 배포 ARN"
  value       = aws_cloudfront_distribution.s3_distribution.arn
}

output "distribution_domain_name" {
  description = "CloudFront 도메인 이름"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "distribution_hosted_zone_id" {
  description = "CloudFront 호스팅 영역 ID"
  value       = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
}