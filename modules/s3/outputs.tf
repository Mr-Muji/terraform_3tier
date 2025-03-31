output "bucket_id" {
  description = "생성된 S3 버킷 ID"
  value       = aws_s3_bucket.web.id
}

output "bucket_arn" {
  description = "생성된 S3 버킷 ARN"
  value       = aws_s3_bucket.web.arn
}

output "bucket_domain_name" {
  description = "S3 버킷 도메인 이름"
  value       = aws_s3_bucket.web.bucket_regional_domain_name
}

output "bucket_name" {
  description = "S3 버킷 이름"
  value       = aws_s3_bucket.web.bucket
}