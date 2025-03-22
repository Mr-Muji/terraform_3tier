variable "prefix" {
  description = "모든 리소스 이름에 사용될 접두사"
  type        = string
}

variable "ecr_name" {
  description = "ECR 저장소 이름"
  type        = string
}

variable "common_tags" {
  description = "모든 리소스에 적용될 공통 태그"
  type        = map(string)
  default     = {}
}

variable "image_tag_mutability" {
  description = "이미지 태그 변경 가능 여부"
  type        = string
  default     = "MUTABLE"
  # 가능한 값: MUTABLE, IMMUTABLE
}

variable "scan_on_push" {
  description = "이미지 푸시 시 스캔 여부"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "암호화 유형"
  type        = string
  default     = "AES256"
  # 가능한 값: AES256, KMS
}

# ArgoCD 관련 변수
variable "install_argocd" {
  description = "ArgoCD 설치 여부"
  type        = bool
  default     = false
}

variable "argocd_namespace" {
  description = "ArgoCD가 설치될 네임스페이스"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "설치할 ArgoCD Helm 차트 버전"
  type        = string
  default     = "5.51.4"
}

variable "argocd_admin_password_hash" {
  description = "ArgoCD 관리자 비밀번호 해시 (bcrypt 형식)"
  type        = string
  sensitive   = true
  default     = "$2a$10$rRyBsGSHK6.uc8fntPwVIuLVHgsAhAX7TcdrqW/RADU0uh7CaChLa" # 'admin' 비밀번호의 해시
}

variable "git_repo_url" {
  description = "프론트엔드 매니페스트가 저장된 Git 저장소 URL"
  type        = string
  default     = ""
}

variable "git_target_revision" {
  description = "사용할 Git 브랜치 또는 태그"
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

variable "ingress_enabled" {
  description = "ArgoCD 인그레스 활성화 여부"
  type        = bool
  default     = true
}

variable "ingress_host" {
  description = "ArgoCD 인그레스 호스트 이름"
  type        = string
  default     = "argocd.example.com"
}

variable "ingress_class" {
  description = "사용할 인그레스 클래스"
  type        = string
  default     = "alb"
}

variable "ingress_annotations" {
  description = "인그레스 추가 설정"
  type        = map(string)
  default     = {
    "kubernetes.io/ingress.class"               = "alb"
    "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
    "alb.ingress.kubernetes.io/target-type"     = "ip"
    "alb.ingress.kubernetes.io/healthcheck-path" = "/"
  }
}

# ECR 이미지 관련 변수
variable "frontend_image_tag" {
  description = "사용할 프론트엔드 이미지 태그"
  type        = string
  default     = "latest"
}

variable "ecr_auth_token" {
  description = "ECR 인증 토큰 (보통 자동으로 생성)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "frontend_ingress_host" {
  description = "프론트엔드 인그레스 호스트 이름"
  type        = string
  default     = "frontend.example.com"
}