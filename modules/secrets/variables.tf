/**
 * AWS Secrets Manager 모듈의 변수 정의 파일
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

variable "db_username" {
  description = "데이터베이스 관리자 사용자 이름"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "데이터베이스 관리자 비밀번호"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "데이터베이스 이름"
  type        = string
}

variable "eks_node_role_name" {
  description = "EKS 노드 IAM 역할 이름 (시크릿 접근 권한 부여용)"
  type        = string
  default     = ""
}

variable "github_token" {
  description = "GitHub 접근 토큰 (매니페스트 레포 업데이트용)"
  type        = string
  sensitive   = true
  default     = ""
}

# Jenkins 관련 변수 추가
variable "jenkins_admin_password" {
  description = "Jenkins 관리자 비밀번호"
  type        = string
  sensitive   = true
  default     = ""
}

variable "aws_access_key" {
  description = "AWS 접근 키 (Jenkins 파이프라인용)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS 시크릿 키 (Jenkins 파이프라인용)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "dockerhub_username" {
  description = "Docker Hub 사용자명 (Jenkins 파이프라인용)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "dockerhub_password" {
  description = "Docker Hub 비밀번호 (Jenkins 파이프라인용)"
  type        = string
  sensitive   = true
  default     = ""
}