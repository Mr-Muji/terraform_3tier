# modules/frontend/variables.tf

variable "environment" {
  description = "배포 환경 (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "프로젝트 이름"
  type        = string
  default     = "tier3"
}

variable "domain_name" {
  description = "프로젝트의 도메인 이름"
  type        = string
  default     = "mydairy.my"
}

variable "zone_id" {
  description = "Route 53 호스팅 영역 ID (비어 있으면 DNS 레코드가 생성되지 않음)"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ACM 인증서 ARN (비어 있으면 CloudFront 기본 인증서 사용)"
  type        = string
  default     = ""
}