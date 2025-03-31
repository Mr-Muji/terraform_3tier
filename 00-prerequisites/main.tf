#---------------------------------------
# S3 버킷 생성 (프론트엔드 정적 파일 호스팅용)
#---------------------------------------

# 프론트엔드 S3 버킷 생성
resource "aws_s3_bucket" "frontend" {
  # 생성 여부 제어
  count  = local.create_frontend_s3 ? 1 : 0
  
  # 버킷 이름 설정
  bucket = "${local.project_name}-${local.environment}-frontend"
  
  # 태그 설정
  tags = merge(local.common_tags, {
    Name = "${local.project_name}-${local.environment}-frontend"
    Service = "frontend-hosting"
  })
}

#---------------------------------------
# 버킷 버저닝 설정
#---------------------------------------
resource "aws_s3_bucket_versioning" "frontend" {
  count  = local.create_frontend_s3 ? 1 : 0
  
  bucket = aws_s3_bucket.frontend[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

#---------------------------------------
# 버킷 암호화 설정
#---------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  count  = local.create_frontend_s3 ? 1 : 0
  
  bucket = aws_s3_bucket.frontend[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#---------------------------------------
# 퍼블릭 액세스 차단 설정
#---------------------------------------
resource "aws_s3_bucket_public_access_block" "frontend" {
  count  = local.create_frontend_s3 ? 1 : 0
  
  bucket = aws_s3_bucket.frontend[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#---------------------------------------
# CORS 설정
#---------------------------------------
resource "aws_s3_bucket_cors_configuration" "frontend" {
  count  = local.create_frontend_s3 ? 1 : 0
  
  bucket = aws_s3_bucket.frontend[0].id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["https://${local.domain_name}", "https://www.${local.domain_name}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

#---------------------------------------
# CloudFront 배포 생성
#---------------------------------------

# OAC(Origin Access Control) 생성
resource "aws_cloudfront_origin_access_control" "frontend" {
  provider                          = aws.us-east-1
  name                              = "${local.project_name}-${local.environment}-frontend-oac"
  description                       = "OAC for ${local.project_name} frontend S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront 배포 생성
resource "aws_cloudfront_distribution" "frontend" {
  # count 조건
  count    = local.create_cloudfront ? 1 : 0
  provider = aws.us-east-1

  # 오리진 설정 - S3 버킷
  origin {
    domain_name              = aws_s3_bucket.frontend[0].bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.frontend[0].bucket}"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  # 배포 설정
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Frontend distribution for ${local.project_name}"
  default_root_object = "index.html"
  price_class         = local.cloudfront_price_class
  aliases             = [local.domain_name]
  
  # SPA를 위한 오류 페이지 설정
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }
  
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  # 기본 캐시 동작 설정
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.frontend[0].bucket}"
    
    # 캐싱 정책
    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
      headers = ["Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers"]
    }
    
    # HTTPS 리다이렉트
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 0
    default_ttl            = 3600  # 1시간
    max_ttl                = 86400 # 1일
  }

  # 지리적 제한 설정
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # SSL 인증서 설정
  viewer_certificate {
    acm_certificate_arn      = local.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # 태그 설정
  tags = merge(local.common_tags, {
    Name    = "${local.project_name}-${local.environment}-cloudfront"
    Service = "frontend-distribution"
  })
  
  # S3 버킷에 의존성 추가
  depends_on = [aws_s3_bucket.frontend]
}

# S3 버킷 정책 업데이트 - CloudFront 접근 허용
resource "aws_s3_bucket_policy" "frontend" {
  count = local.create_frontend_s3 && local.create_cloudfront ? 1 : 0
  
  bucket = aws_s3_bucket.frontend[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend[0].arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.frontend[0].arn
          }
        }
      }
    ]
  })
  
  # S3 버킷과 CloudFront에 의존성 추가
  depends_on = [
    aws_s3_bucket.frontend,
    aws_cloudfront_distribution.frontend
  ]
  
  # 이미 존재하는 정책에서 변경을 무시
  lifecycle {
    ignore_changes = [policy]
  }
}

#---------------------------------------
# Route53 레코드 생성
#---------------------------------------

# mydairy.my 도메인을 CloudFront에 연결
resource "aws_route53_record" "frontend" {
  count = local.create_cloudfront && local.create_route53_records ? 1 : 0
  
  zone_id = local.zone_id
  name    = local.domain_name
  type    = "A"
  
  alias {
    name                   = aws_cloudfront_distribution.frontend[0].domain_name
    zone_id                = aws_cloudfront_distribution.frontend[0].hosted_zone_id
    evaluate_target_health = false
  }
}

# www.mydairy.my 서브도메인 추가 (선택 사항)
resource "aws_route53_record" "www" {
  count = local.create_cloudfront && local.create_route53_records ? 1 : 0
  
  zone_id = local.zone_id
  name    = "www.${local.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [local.domain_name]
}

#---------------------------------------
# ECR 저장소 생성
# 프론트엔드 및 백엔드 애플리케이션용 컨테이너 이미지 저장소
#---------------------------------------

# 프론트엔드 ECR 저장소 생성
module "frontend_ecr" {
  # 생성 여부 제어
  count  = local.create_frontend_ecr ? 1 : 0
  source = "../modules/ecr"
  
  repository_name = "${local.project_name}-frontend"
  component_name  = "frontend"
  
  # 이미지 설정
  image_tag_mutability = local.ecr_image_tag_mutability
  scan_on_push         = local.ecr_scan_on_push
  force_delete         = local.ecr_force_delete
  
  # 라이프사이클 설정
  enable_lifecycle_policy = local.ecr_lifecycle_policy_enabled
  keep_image_count        = local.ecr_keep_image_count
  
  # 태그 설정
  common_tags = local.common_tags
  additional_tags = {
    ApplicationType = "frontend"
    Service         = "web"
    CreatedBy       = "terraform-00-pre"
  }
}

# 백엔드 ECR 저장소 생성
module "backend_ecr" {
  # 생성 여부 제어
  count  = local.create_backend_ecr ? 1 : 0
  source = "../modules/ecr"
  
  repository_name = "${local.project_name}-backend"
  component_name  = "backend"
  
  # 이미지 설정
  image_tag_mutability = local.ecr_image_tag_mutability
  scan_on_push         = local.ecr_scan_on_push
  force_delete         = local.ecr_force_delete
  
  # 라이프사이클 설정
  enable_lifecycle_policy = local.ecr_lifecycle_policy_enabled
  keep_image_count        = local.ecr_keep_image_count
  
  # 태그 설정
  common_tags = local.common_tags
  additional_tags = {
    ApplicationType = "backend"
    Service         = "api"
    CreatedBy       = "terraform-00-pre"
  }
}
