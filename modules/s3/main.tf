#---------------------------------------
# S3 버킷 생성
#---------------------------------------
resource "aws_s3_bucket" "web" {
  bucket = "${var.project_name}-${var.environment}-web"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-web"
  })
}

#---------------------------------------
# 버킷 버저닝 설정
#---------------------------------------
resource "aws_s3_bucket_versioning" "web" {
  bucket = aws_s3_bucket.web.id
  versioning_configuration {
    status = "Enabled"
  }
}

#---------------------------------------
# 버킷 정책 설정 - CloudFront 접근 허용
#---------------------------------------
resource "aws_s3_bucket_policy" "web" {
  bucket = aws_s3_bucket.web.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.web.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = var.cloudfront_distribution_arn
          }
        }
      }
    ]
  })
}

#---------------------------------------
# CORS 설정
#---------------------------------------
resource "aws_s3_bucket_cors_configuration" "web" {
  bucket = aws_s3_bucket.web.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["https://${var.domain_name}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

#---------------------------------------
# 버킷 암호화 설정
#---------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "web" {
  bucket = aws_s3_bucket.web.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#---------------------------------------
# 퍼블릭 액세스 차단 설정
#---------------------------------------
resource "aws_s3_bucket_public_access_block" "web" {
  bucket = aws_s3_bucket.web.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}