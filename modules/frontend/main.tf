#=======================================================
# 프론트엔드 모듈 - 웹 호스팅 관련 리소스 생성
#=======================================================
# 이 모듈에서 생성하는 리소스:
# 1. S3 버킷 및 관련 설정
# 2. CloudFront 배포
# 3. Route53 DNS 레코드
#=======================================================

#---------------------------------------
# 1. S3 버킷 생성 (프론트엔드 정적 파일 호스팅용)
#---------------------------------------

# 프론트엔드 S3 버킷 생성
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "${var.project_name}-frontend-bucket"  # 버킷 이름 설정
  
  force_destroy = var.force_destroy  # 내용물이 있어도 삭제 가능 여부
  
  tags = var.common_tags  # 공통 태그 적용
}

#---------------------------------------
# 1-1. 버킷 버저닝 설정 - 객체 버전 관리 활성화
#---------------------------------------
resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend_bucket.id  # 적용할 버킷 ID
  versioning_configuration {
    status = "Enabled"  # 버전 관리 활성화
  }
}

#---------------------------------------
# 1-2. 버킷 암호화 설정 - 데이터 보안 강화
#---------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend_bucket.id  # 적용할 버킷 ID

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # AES-256 암호화 알고리즘 사용
    }
  }
}

#---------------------------------------
# 1-3. 퍼블릭 액세스 차단 설정 - 보안 강화
#---------------------------------------
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend_bucket.id  # 적용할 버킷 ID

  # 모든 퍼블릭 액세스 차단 설정
  block_public_acls       = true  # 퍼블릭 ACL 차단
  block_public_policy     = true  # 퍼블릭 정책 차단
  ignore_public_acls      = true  # 기존 퍼블릭 ACL 무시
  restrict_public_buckets = true  # 퍼블릭 버킷 액세스 제한
}

#---------------------------------------
# 1-4. CORS 설정 - 교차 출처 리소스 공유 설정
#---------------------------------------
resource "aws_s3_bucket_cors_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend_bucket.id  # 적용할 버킷 ID

  cors_rule {
    allowed_headers = ["*"]  # 모든 헤더 허용
    allowed_methods = ["GET", "HEAD"]  # 허용할 HTTP 메서드
    allowed_origins = ["https://${var.domain_name}", "https://www.${var.domain_name}"]  # 허용할 오리진
    expose_headers  = ["ETag"]  # 노출할 헤더
    max_age_seconds = 3000  # 프리플라이트 요청 캐싱 시간(초)
  }
}

#---------------------------------------
# 2. CloudFront 배포 생성 - 전역 콘텐츠 전송 네트워크
#---------------------------------------

# 2-1. OAC(Origin Access Control) 생성 - S3 버킷에 대한 안전한 접근 제어
resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "${var.project_name}-${var.environment}-frontend-oac"  # OAC 이름
  description                       = "OAC for ${var.project_name} frontend S3 bucket"  # 설명
  origin_access_control_origin_type = "s3"  # S3 타입 설정
  signing_behavior                  = "always"  # 항상 서명
  signing_protocol                  = "sigv4"  # 서명 프로토콜
}

# 2-2. CloudFront 배포 생성 - 콘텐츠 전송 네트워크 배포
resource "aws_cloudfront_distribution" "frontend" {
  # 오리진 설정 - S3 버킷 연결
  origin {
    domain_name              = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name  # S3 버킷 도메인
    origin_id                = "S3-${aws_s3_bucket.frontend_bucket.bucket}"  # 오리진 ID
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id  # OAC ID
  }

  # 배포 기본 설정
  enabled             = true  # 배포 활성화
  is_ipv6_enabled     = true  # IPv6 지원
  comment             = "Frontend distribution for ${var.project_name}"  # 설명
  default_root_object = "index.html"  # 기본 루트 객체
  price_class         = var.cloudfront_price_class  # 가격 클래스
  aliases             = [var.domain_name]  # 대체 도메인 이름
  
  # SPA(Single Page Application)를 위한 오류 페이지 설정
  custom_error_response {
    error_code         = 403  # 접근 금지 에러
    response_code      = 200  # 응답 코드
    response_page_path = "/index.html"  # 응답 페이지 경로
  }
  
  custom_error_response {
    error_code         = 404  # 찾을 수 없음 에러
    response_code      = 200  # 응답 코드
    response_page_path = "/index.html"  # 응답 페이지 경로
  }

  # 기본 캐시 동작 설정
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]  # 허용할 HTTP 메서드
    cached_methods   = ["GET", "HEAD"]  # 캐시할 HTTP 메서드
    target_origin_id = "S3-${aws_s3_bucket.frontend_bucket.bucket}"  # 대상 오리진 ID
    
    # 캐시 및 요청 정책
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"  # CachingOptimized 정책
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"  # CORS-S3Origin 정책
    
    # 뷰어 프로토콜 설정
    viewer_protocol_policy = "redirect-to-https"  # HTTP를 HTTPS로 리다이렉트
    
    # 캐시 키 설정
    compress               = true  # 압축 활성화 (Gzip, Brotli)
  }

  # 제한 설정
  restrictions {
    geo_restriction {
      restriction_type = "none"  # 지역 제한 없음
    }
  }

  # SSL 인증서 설정
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn  # ACM 인증서 ARN
    ssl_support_method       = "sni-only"  # SNI 지원 방식 사용
    minimum_protocol_version = "TLSv1.2_2021"  # 최소 TLS 프로토콜 버전
  }
  
  # 태그 설정
  tags = merge(var.common_tags, {
    Name = "${var.project_name}-frontend-distribution"
  })
}

# 1-5. S3 버킷 정책 설정 - CloudFront만 S3에 접근 허용
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend_bucket.id  # 적용할 버킷 ID
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"  # 정책 ID
        Effect = "Allow"  # 허용
        Principal = {
          Service = "cloudfront.amazonaws.com"  # CloudFront 서비스 주체
        }
        Action   = "s3:GetObject"  # GetObject 작업 허용
        Resource = "${aws_s3_bucket.frontend_bucket.arn}/*"  # 모든 객체에 적용
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.frontend.arn  # 특정 CloudFront 배포만 허용
          }
        }
      }
    ]
  })
  
  # S3 버킷과 CloudFront에 의존성 추가
  depends_on = [
    aws_s3_bucket.frontend_bucket,
    aws_cloudfront_distribution.frontend
  ]
}

#---------------------------------------
# 3. Route53 레코드 생성 - DNS 설정
#---------------------------------------

# 3-1. 메인 도메인 레코드 생성
resource "aws_route53_record" "frontend" {
  count = var.create_route53_records ? 1 : 0  # 조건부 생성
  
  zone_id = var.zone_id  # 호스팅 영역 ID
  name    = var.domain_name  # 도메인 이름
  type    = "A"  # A 레코드 타입
  
  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name  # CloudFront 도메인 이름
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id  # CloudFront 호스팅 영역 ID
    evaluate_target_health = false  # 대상 상태 평가 비활성화
  }
}

# 3-2. www 서브도메인 레코드 생성 
resource "aws_route53_record" "www" {
  count = var.create_route53_records ? 1 : 0  # 조건부 생성
  
  zone_id = var.zone_id  # 호스팅 영역 ID
  name    = "www.${var.domain_name}"  # www 서브도메인
  type    = "CNAME"  # CNAME 레코드 타입
  ttl     = 300  # TTL 300초
  records = [var.domain_name]  # 메인 도메인으로 연결
}
