#---------------------------------------
# 데이터베이스 시크릿 변수
#---------------------------------------
variable "db_username" {
  description = "데이터베이스 사용자 이름"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "데이터베이스 비밀번호"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "데이터베이스 이름"
  type        = string
}

#---------------------------------------
# GitHub 토큰 변수
#---------------------------------------
variable "github_token" {
  description = "GitHub 접근 토큰 (매니페스트 레포 업데이트용)"
  type        = string
  sensitive   = true
  default     = ""  # 기본값으로 빈 문자열 설정
}

#---------------------------------------
# Jenkins 관련 변수
#---------------------------------------
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