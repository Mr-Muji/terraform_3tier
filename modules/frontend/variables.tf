#---------------------------------------
# 프론트엔드 모듈 입력 변수
#---------------------------------------

# 1. 프로젝트 기본 정보
variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "배포 환경 (dev, stage, prod 등)"
  type        = string
}

# 2. 도메인 설정
variable "domain_name" {
  description = "웹사이트 도메인 이름"
  type        = string
}

variable "zone_id" {
  description = "Route53 호스팅 영역 ID"
  type        = string
}

# 3. CloudFront 설정
variable "cloudfront_price_class" {
  description = "CloudFront 가격 등급"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM 인증서 ARN (반드시 us-east-1 리전에 있어야 함)"
  type        = string
}

# 4. 리소스 생성 제어 플래그
variable "create_route53_records" {
  description = "Route53 DNS 레코드 생성 여부"
  type        = bool
}

# 5. S3 설정
variable "force_destroy" {
  description = "S3 버킷 삭제 시 내용물도 함께 삭제할지 여부"
  type        = bool
}

# 6. 공통 태그
variable "common_tags" {
  description = "모든 리소스에 적용할 공통 태그"
  type        = map(string)
}

# 버킷 이름 패턴 커스터마이징
variable "bucket_name_prefix" {
  description = "S3 버킷 이름 프리픽스. 기본값은 project_name"
  type        = string
}

# CORS 설정
variable "cors_origins" {
  description = "CORS 허용 오리진 목록"
  type        = list(string)
}

# CloudFront 캐시 정책 설정
variable "cache_policy_id" {
  description = "CloudFront 캐시 정책 ID"
  type        = string
}
