variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "배포 환경 (dev, prod 등)"
  type        = string
}

variable "domain_name" {
  description = "웹사이트 도메인 이름"
  type        = string
}

variable "bucket_name" {
  description = "S3 버킷 이름"
  type        = string
}

variable "bucket_domain_name" {
  description = "S3 버킷 도메인 이름"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM 인증서 ARN"
  type        = string
}

variable "price_class" {
  description = "CloudFront 가격 등급"
  type        = string
  default     = "PriceClass_100" # 북미 및 유럽만 (가장 저렴)
  # 다른 옵션: "PriceClass_200" (북미, 유럽, 아시아), "PriceClass_All" (전체 지역)
}

variable "common_tags" {
  description = "모든 리소스에 적용할 공통 태그"
  type        = map(string)
  default     = {}
}

# 새로 추가된 변수들

variable "enabled" {
  description = "CloudFront 배포 활성화 여부"
  type        = bool
  default     = true
}

variable "enable_ipv6" {
  description = "IPv6 지원 활성화 여부"
  type        = bool
  default     = true
}

variable "default_root_object" {
  description = "기본 루트 객체 (일반적으로 index.html)"
  type        = string
  default     = "index.html"
}

variable "custom_aliases" {
  description = "CloudFront 배포에 연결할 커스텀 도메인 이름 목록"
  type        = list(string)
  default     = null
}

variable "spa_error_responses" {
  description = "SPA 라우팅을 위한 오류 응답 설정"
  type        = list(object({
    error_code         = number
    response_code      = number
    response_page_path = string
  }))
  default = [
    {
      error_code         = 403
      response_code      = 200
      response_page_path = "/index.html"
    },
    {
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
    }
  ]
}

variable "allowed_methods" {
  description = "허용된 HTTP 메서드 목록"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cached_methods" {
  description = "캐싱할 HTTP 메서드 목록"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "viewer_protocol_policy" {
  description = "뷰어 프로토콜 정책"
  type        = string
  default     = "redirect-to-https"
  # 다른 옵션: "allow-all", "https-only"
}

variable "enable_compression" {
  description = "콘텐츠 압축 활성화 여부"
  type        = bool
  default     = true
}

variable "geo_restriction_type" {
  description = "지리적 제한 유형"
  type        = string
  default     = "none"
  # 다른 옵션: "whitelist", "blacklist"
}

variable "geo_restriction_locations" {
  description = "허용 또는 차단할 국가 코드 목록(ISO 3166-1-alpha-2 코드)"
  type        = list(string)
  default     = []
}

variable "min_ssl_protocol_version" {
  description = "최소 SSL 프로토콜 버전"
  type        = string
  default     = "TLSv1.2_2021"
}

variable "default_ttl" {
  description = "기본 TTL(초)"
  type        = number
  default     = 86400 # 1일
}

variable "max_ttl" {
  description = "최대 TTL(초)"
  type        = number
  default     = 31536000 # 1년
}

variable "min_ttl" {
  description = "최소 TTL(초)"
  type        = number
  default     = 1 # 1초
}

variable "cookie_behavior" {
  description = "쿠키 동작 방식"
  type        = string
  default     = "none"
  # 다른 옵션: "all", "whitelist", "allExcept"
}

variable "header_behavior" {
  description = "헤더 동작 방식"
  type        = string
  default     = "whitelist"
  # 다른 옵션: "none", "allViewer", "allViewerAndWhitelistCloudFront"
}

variable "forwarded_headers" {
  description = "오리진으로 전달할 헤더 목록"
  type        = list(string)
  default     = ["Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers"]
}

variable "query_string_behavior" {
  description = "쿼리 문자열 동작 방식"
  type        = string
  default     = "all"
  # 다른 옵션: "none", "whitelist", "allExcept"
}

variable "cors_allow_credentials" {
  description = "CORS credentials 허용 여부"
  type        = bool
  default     = false
}

variable "cors_allowed_headers" {
  description = "CORS에서 허용할 헤더 목록"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allowed_methods" {
  description = "CORS에서 허용할 메서드 목록"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cors_allowed_origins" {
  description = "CORS에서 허용할 오리진 목록 (null일 경우 도메인 이름 자동 사용)"
  type        = list(string)
  default     = null
}

variable "enable_security_headers" {
  description = "보안 헤더 설정 활성화 여부"
  type        = bool
  default     = true
}

variable "frame_option" {
  description = "X-Frame-Options 헤더 값"
  type        = string
  default     = "DENY"
  # 다른 옵션: "SAMEORIGIN"
}

variable "hsts_max_age" {
  description = "Strict Transport Security 헤더의 max-age 값(초)"
  type        = number
  default     = 31536000 # 1년
}

variable "hsts_include_subdomains" {
  description = "Strict Transport Security 헤더의 includeSubdomains 옵션 활성화 여부"
  type        = bool
  default     = true
}

variable "xss_mode_block" {
  description = "XSS Protection 헤더의 mode=block 옵션 활성화 여부"
  type        = bool
  default     = true
}