#-------------------------------------------------------
# CICD 모듈 변수
#-------------------------------------------------------

# 프로젝트 기본 변수
variable "prefix" {
  description = "리소스 이름에 사용할 접두사"
  type        = string
  default     = "tier3"
}

variable "environment" {
  description = "배포 환경 (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "common_tags" {
  description = "모든 리소스에 적용할 태그"
  type        = map(string)
  default     = {}
}

variable "ecr_name" {
  description = "ECR 저장소 이름 접두사"
  type        = string
  default     = "tier3-ecr"
}

# ECR 관련 변수
variable "image_tag_mutability" {
  description = "ECR 이미지 태그 변경 가능 여부"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "이미지 업로드 시 자동 스캔 여부"
  type        = bool
  default     = true
}

variable "ecr_force_delete" {
  description = "저장소 내 이미지가 있어도 강제 삭제 여부"
  type        = bool
  default     = false
}

variable "ecr_max_images" {
  description = "ECR에 보관할 최대 이미지 수"
  type        = number
  default     = 10
}

variable "frontend_image_tag" {
  description = "프론트엔드 이미지 태그"
  type        = string
  default     = "latest"
}

variable "backend_image_tag" {
  description = "백엔드 이미지 태그"
  type        = string
  default     = "latest"
}

# EKS 클러스터 관련 변수
variable "eks_cluster_id" {
  description = "EKS 클러스터 ID"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "EKS 클러스터 API 엔드포인트"
  type        = string
  default     = ""
}

variable "eks_cluster_ca_data" {
  description = "EKS 클러스터 CA 인증서 데이터"
  type        = string
  default     = ""
}

variable "cluster_exists" {
  description = "EKS 클러스터가 이미 존재하는지 여부"
  type        = bool
  default     = false
}

# ArgoCD 관련 변수
variable "argocd_namespace" {
  description = "ArgoCD 네임스페이스"
  type        = string
  default     = "argocd"
}

# 프론트엔드 애플리케이션 관련 변수
variable "git_repo_url" {
  description = "프론트엔드 소스 코드가 있는 Git 저장소"
  type        = string
  default     = "https://github.com/example/frontend-app.git"
}

variable "git_target_revision" {
  description = "Git 저장소의 브랜치 또는 태그"
  type        = string
  default     = "main"
}

variable "frontend_manifest_path" {
  description = "Git 저장소 내 프론트엔드 매니페스트 경로"
  type        = string
  default     = "k8s"
}

variable "frontend_namespace" {
  description = "프론트엔드 애플리케이션이 배포될 네임스페이스"
  type        = string
  default     = "frontend"
}

# 도메인 설정 관련 변수
variable "domain_name" {
  description = "도메인 이름"
  type        = string
  default     = "example.com"
}

variable "zone_id" {
  description = "Route53 호스팅 존 ID"
  type        = string
  default     = ""
}

variable "frontend_ingress_host" {
  description = "프론트엔드 인그레스 호스트 이름"
  type        = string
  default     = "frontend.example.com"
}

variable "frontend_ingress_name" {
  description = "프론트엔드 인그레스 이름"
  type        = string
  default     = "frontend"
}

# 기타 설정
variable "k8s_cleanup_wait_seconds" {
  description = "쿠버네티스 리소스 정리 대기 시간 (초)"
  type        = number
  default     = 120
}

variable "ecr_auth_token" {
  description = "ECR 인증 토큰"
  type        = string
  default     = ""
  sensitive   = true
}

# Helm 차트 관련 변수
variable "helm_charts_repo_url" {
  description = "Helm 차트가 저장된 Git 저장소 URL"
  type        = string
  default     = ""
}

variable "helm_charts_repo_path" {
  description = "Helm 차트 저장소 내 경로"
  type        = string
  default     = "charts"
}

variable "helm_charts_revision" {
  description = "Helm 차트 저장소의 브랜치 또는 태그"
  type        = string
  default     = "main"
}

variable "backend_namespace" {
  description = "백엔드 애플리케이션이 배포될 네임스페이스"
  type        = string
  default     = "backend"
}
