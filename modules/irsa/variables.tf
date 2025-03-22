/**
 * IRSA(IAM Roles for Service Accounts) 모듈 변수 정의 파일
 */

variable "prefix" {
  description = "리소스 이름에 사용할 접두사"
  type        = string
}

variable "common_tags" {
  description = "모든 리소스에 적용할 공통 태그"
  type        = map(string)
  default     = {}
}

variable "eks_oidc_provider_url" {
  description = "EKS OIDC 제공자 URL (https://로 시작)"
  type        = string
}

variable "service_account_name" {
  description = "생성할 Kubernetes 서비스 계정 이름"
  type        = string
}

variable "k8s_namespace" {
  description = "서비스 계정이 생성될 Kubernetes 네임스페이스"
  type        = string
  default     = "default"
}

variable "policy_arns" {
  description = "서비스 계정에 연결할 IAM 정책 ARN 목록"
  type        = list(string)
}

variable "create_k8s_service_account" {
  description = "Kubernetes 서비스 계정을 생성할지 여부"
  type        = bool
  default     = true
}