# Jenkins 모듈 변수 정의

# 기본 설정
variable "name_prefix" {
  description = "리소스 이름 접두사"
  type        = string
}

variable "environment" {
  description = "배포 환경 (dev, staging, prod)"
  type        = string
}

variable "namespace" {
  description = "Jenkins 설치할 네임스페이스"
  type        = string
  default     = "jenkins"  # 기본값 설정
}

# EKS 클러스터 관련 설정
variable "oidc_provider_arn" {
  description = "EKS OIDC 제공자 ARN"
  type        = string
}

# Helm 차트 관련 설정
variable "jenkins_chart_version" {
  description = "Jenkins Helm 차트 버전"
  type        = string
}

variable "jenkins_service_type" {
  description = "Jenkins 서비스 타입"
  type        = string
  default     = "ClusterIP"  # 기본값: ClusterIP (클러스터 내부에서만 접근 가능)
}

# 스토리지 관련 설정
variable "jenkins_pvc_size" {
  description = "Jenkins PVC 크기"
  type        = string
}

variable "storage_class_name" {
  description = "Jenkins에서 사용할 스토리지 클래스 이름 (이 이름으로 스토리지 클래스가 생성됩니다)"
  type        = string
}

# Ingress 관련 설정
variable "ingress_enabled" {
  description = "인그레스 사용 여부"
  type        = bool
}

variable "ingress_host" {
  description = "인그레스 호스트 이름"
  type        = string
  default     = ""  # 기본값 없음
}

variable "ingress_class" {
  description = "인그레스 클래스"
  type        = string
  default     = "alb"  # AWS ALB 인그레스 컨트롤러
}

# 인증 관련 설정
variable "jenkins_admin_user" {
  description = "Jenkins 관리자 사용자명"
  type        = string
  default     = "admin"  # 기본 관리자 계정
}

variable "jenkins_admin_password" {
  description = "Jenkins 관리자 비밀번호"
  type        = string
  sensitive   = true  # 민감 정보로 표시 (로그에 출력 안 됨)
}

# ECR 관련 설정
variable "backend_ecr_url" {
  description = "백엔드 ECR 저장소 URL"
  type        = string
}

variable "backend_ecr_name" {
  description = "백엔드 ECR 저장소 이름"
  type        = string
}

# GitHub 관련 설정
variable "backend_repo_url" {
  description = "백엔드 Git 저장소 URL"
  type        = string
}

variable "backend_repo_org" {
  description = "백엔드 레포지토리 GitHub 조직명"
  type        = string
  default     = "your-org"  # 기본값
}

variable "backend_repo_branch" {
  description = "백엔드 레포지토리 브랜치"
  type        = string
  default     = "main"  # 기본 브랜치
}

# 젠킨스 작업 관련 설정
variable "jenkins_job_suffix" {
  description = "Jenkins 작업 이름 접미사"
  type        = string
  default     = "pipeline"  # 기본 접미사
}

variable "job_description" {
  description = "Jenkins 작업 설명"
  type        = string
  default     = "백엔드 애플리케이션 빌드 및 ECR 배포 파이프라인"  # 기본 설명
}

variable "scm_poll_interval" {
  description = "SCM 폴링 간격 (Jenkins cron 구문)"
  type        = string
  default     = "H/5 * * * *"  # 기본 5분마다 폴링
}

# 시크릿 관련 설정
variable "github_token_secret_arn" {
  description = "GitHub 토큰이 저장된 AWS Secrets Manager ARN"
  type        = string
  default     = ""
}

variable "jenkins_secret_arn" {
  description = "Jenkins 시크릿 ARN (AWS Secrets Manager)"
  type        = string
  default     = ""
}

# 태그 설정
variable "tags" {
  description = "리소스에 적용할 태그"
  type        = map(string)
  default     = {}  # 기본 태그 없음
}