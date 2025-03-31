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

variable "cloudfront_distribution_arn" {
  description = "CloudFront 배포 ARN"
  type        = string
}

variable "common_tags" {
  description = "모든 리소스에 적용할 공통 태그"
  type        = map(string)
  default     = {}
}