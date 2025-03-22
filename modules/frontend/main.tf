# modules/frontend/main.tf

#======================================================
# 1. 기본 인프라 리소스
#======================================================

#---------------------------------------
# 프론트엔드 정적 웹 호스팅을 위한 S3 버킷 생성
#---------------------------------------
resource "aws_s3_bucket" "frontend" {
  bucket = "frontend-${var.project_name}-${var.environment}"

  # 버킷 삭제 시 모든 객체도 함께 삭제 (테스트 환경에서만 권장)
  force_destroy = true

  tags = {
    Name        = "frontend-${var.project_name}"
    Environment = var.environment
    Project     = var.project_name
  }
}

#======================================================
# 2. 연관된 설정
#======================================================

#---------------------------------------
# S3 버킷을 웹사이트로 구성 (정적 웹 호스팅 활성화)
#---------------------------------------
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html" # React SPA를 위한 설정 - 모든 경로가 index.html로 라우팅됨
  }
}

#---------------------------------------
# 버킷 공개 액세스 차단 설정 (보안 강화)
#---------------------------------------
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true # ACL을 통한 공개 액세스 차단
  block_public_policy     = true # 공개 버킷 정책 설정 차단
  ignore_public_acls      = true # 기존 공개 ACL 무시
  restrict_public_buckets = true # 공개 정책이 있는 버킷에 대한 액세스 제한
}

#======================================================
# 3. 접근 권한 관련 리소스
#======================================================

#---------------------------------------
# CloudFront Origin Access Identity 생성 (S3 보안 접근용)
#---------------------------------------
resource "aws_cloudfront_origin_access_identity" "frontend_oai" {
  comment = "${var.project_name}-${var.environment} S3 버킷 접근용 OAI"
}

#---------------------------------------
# S3 버킷 정책 - CloudFront OAI에만 접근 허용
#---------------------------------------
resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.frontend_oai.id}"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}

#======================================================
# 4. 서비스 구축 (CloudFront)
#======================================================

#---------------------------------------
# CloudFront 배포 생성 (CDN 및 HTTPS 제공)
#---------------------------------------
resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true # 배포 활성화
  is_ipv6_enabled     = true # IPv6 지원 활성화
  comment             = "${var.project_name} 프론트엔드 배포"
  default_root_object = "index.html"     # 기본 문서 설정
  price_class         = "PriceClass_100" # 북미, 유럽 지역만 사용 (비용 절감)

  # 사용자 지정 도메인 설정
  aliases = [var.domain_name]
  # aliases = [var.domain_name, "www.${var.domain_name}"]  # 필요시 www 도메인 추가

  #---------------------------------------
  # 오리진 설정 - S3 버킷
  #---------------------------------------
  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name # S3 버킷의 리전별 도메인 이름
    origin_id   = "S3-${aws_s3_bucket.frontend.bucket}"              # 오리진 식별자

    # OAI를 통한 보안 접근 설정
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend_oai.cloudfront_access_identity_path
    }
  }

  #---------------------------------------
  # 기본 캐시 동작 설정
  #---------------------------------------
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.frontend.bucket}" # 오리진 ID와 정확히 일치하도록 수정

    # 요청/응답 헤더 및 쿠키 설정
    forwarded_values {
      query_string = false # 쿼리 문자열 미전달
      cookies {
        forward = "none" # 쿠키 미전달
      }
    }

    viewer_protocol_policy = "redirect-to-https" # HTTP를 HTTPS로 리다이렉트
    min_ttl                = 0                   # 최소 캐시 시간 (초)
    default_ttl            = 3600                # 기본 캐시 시간 (1시간)
    max_ttl                = 86400               # 최대 캐시 시간 (24시간)
    compress               = true                # 압축 활성화
  }

  #---------------------------------------
  # SPA 라우팅을 위한 오류 페이지 설정
  #---------------------------------------
  # React Router 등 클라이언트 사이드 라우팅 지원을 위한 설정
  custom_error_response {
    error_code            = 403 # 접근 금지 오류
    response_code         = 200 # 성공 응답으로 변경
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10 # 최소 캐시 시간 (초)
  }

  custom_error_response {
    error_code            = 404 # 페이지 없음 오류
    response_code         = 200 # 성공 응답으로 변경
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10 # 최소 캐시 시간 (초)
  }

  #---------------------------------------
  # 지리적 제한 설정
  #---------------------------------------
  restrictions {
    geo_restriction {
      restriction_type = "none" # 지리적 제한 없음
    }
  }

  #---------------------------------------
  # SSL 인증서 설정
  #---------------------------------------
  viewer_certificate {
    # 제공된 인증서가 있으면 사용, 없으면 CloudFront 기본 인증서 사용
    acm_certificate_arn            = var.certificate_arn != "" ? var.certificate_arn : null
    ssl_support_method             = var.certificate_arn != "" ? "sni-only" : null
    minimum_protocol_version       = var.certificate_arn != "" ? "TLSv1.2_2021" : null
    cloudfront_default_certificate = var.certificate_arn == "" ? true : false
  }

  # 명시적 의존성 추가
  depends_on = [
    aws_s3_bucket.frontend,
    aws_cloudfront_origin_access_identity.frontend_oai,
    aws_s3_bucket_policy.frontend_policy
  ]

  tags = {
    Name        = "Frontend-CloudFront"
    Environment = var.environment
    Project     = var.project_name
  }
}

#======================================================
# 5. 최종 사용자 접근 관련 리소스 (DNS)
#======================================================

#---------------------------------------
# Route 53 루트 도메인 레코드 생성
#---------------------------------------
resource "aws_route53_record" "root_domain" {
  # var.zone_id가 제공된 경우에만 레코드 생성
  count   = var.zone_id != "" ? 1 : 0
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  # CloudFront 배포를 가리키는 A 레코드 별칭
  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = false
  }
}

# Route 53 www 서브도메인 레코드 생성
# resource "aws_route53_record" "www" {
#   # var.zone_id가 제공된 경우에만 레코드 생성
#   count   = var.zone_id != "" ? 1 : 0
#   zone_id = var.zone_id
#   name    = "www.${var.domain_name}"
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.frontend.domain_name
#     zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
#     evaluate_target_health = false
#   }
# }
