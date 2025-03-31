#---------------------------------------
# 오리진 액세스 컨트롤 생성 (OAC)
#---------------------------------------
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.project_name}-${var.environment}-oac"
  description                       = "Origin Access Control for ${var.project_name} S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#---------------------------------------
# CloudFront 배포 생성
#---------------------------------------
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = var.bucket_domain_name
    origin_id                = "S3-${var.bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # 활성화 여부 설정
  enabled             = var.enabled
  is_ipv6_enabled     = var.enable_ipv6
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = var.custom_aliases != null ? var.custom_aliases : [var.domain_name]
  
  # SPA를 위한 오류 페이지 설정 (클라이언트 측 라우팅 지원)
  dynamic "custom_error_response" {
    for_each = var.spa_error_responses
    content {
      error_code         = custom_error_response.value.error_code
      response_code      = custom_error_response.value.response_code
      response_page_path = custom_error_response.value.response_page_path
    }
  }

  # 기본 캐시 동작 설정
  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = "S3-${var.bucket_name}"

    # 캐싱 정책
    cache_policy_id = aws_cloudfront_cache_policy.cache_policy.id
    
    # 응답 헤더 정책
    response_headers_policy_id = aws_cloudfront_response_headers_policy.headers_policy.id
    
    # CORS 요청 허용
    viewer_protocol_policy = var.viewer_protocol_policy
    compress               = var.enable_compression
  }

  # 지리적 제한 설정 (선택적)
  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  # SSL 인증서 설정
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = var.min_ssl_protocol_version
  }

  # 태그 설정
  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-cloudfront"
  })

  # 무효화 설정 - 배포 업데이트 시 캐시 무효화 허용
  depends_on = [aws_cloudfront_origin_access_control.oac]
}

#---------------------------------------
# CloudFront 캐시 정책 생성
#---------------------------------------
resource "aws_cloudfront_cache_policy" "cache_policy" {
  name        = "${var.project_name}-${var.environment}-cache-policy"
  comment     = "Cache policy for ${var.project_name} frontend"
  default_ttl = var.default_ttl
  max_ttl     = var.max_ttl
  min_ttl     = var.min_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
    
    cookies_config {
      cookie_behavior = var.cookie_behavior
    }
    
    headers_config {
      header_behavior = var.header_behavior
      headers {
        items = var.forwarded_headers
      }
    }
    
    query_strings_config {
      query_string_behavior = var.query_string_behavior
    }
  }
}

#---------------------------------------
# CloudFront 응답 헤더 정책 생성
#---------------------------------------
resource "aws_cloudfront_response_headers_policy" "headers_policy" {
  name    = "${var.project_name}-${var.environment}-headers-policy"
  comment = "Headers policy for ${var.project_name} frontend"

  # CORS 설정
  cors_config {
    access_control_allow_credentials = var.cors_allow_credentials
    
    access_control_allow_headers {
      items = var.cors_allowed_headers
    }
    
    access_control_allow_methods {
      items = var.cors_allowed_methods
    }
    
    access_control_allow_origins {
      items = var.cors_allowed_origins != null ? var.cors_allowed_origins : ["https://${var.domain_name}"]
    }
    
    origin_override = true
  }

  # 보안 헤더 설정
  dynamic "security_headers_config" {
    for_each = var.enable_security_headers ? [1] : []
    content {
      content_type_options {
        override = true
      }
      
      frame_options {
        frame_option = var.frame_option
        override     = true
      }
      
      strict_transport_security {
        access_control_max_age_sec = var.hsts_max_age
        include_subdomains         = var.hsts_include_subdomains
        override                   = true
      }
      
      xss_protection {
        mode_block = var.xss_mode_block
        protection = true
        override   = true
      }
    }
  }
}