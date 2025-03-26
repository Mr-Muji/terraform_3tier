#-------------------------------------------------------
# ArgoCD 모듈 변수 정의
#-------------------------------------------------------

# 클러스터 관련 변수
variable "eks_cluster_id" {
  description = "EKS 클러스터 ID"
  type        = string
}

variable "region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

# ArgoCD 설정 변수
variable "argocd_namespace" {
  description = "ArgoCD를 설치할 네임스페이스"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "설치할 ArgoCD Helm 차트 버전"
  type        = string
  default     = "5.36.1"
}

variable "argocd_admin_password_hash" {
  description = "ArgoCD 관리자 비밀번호 해시 (bcrypt 형식)"
  type        = string
  sensitive   = true
  # 기본값은 'admin'의 bcrypt 해시
  default     = "$2a$10$rRyBsGSHK6.uc8fntPwVIuLVHgsAhAX7TcdrqW/RADU0uh7CaChLa"
}

# 인그레스 관련 변수
variable "ingress_enabled" {
  description = "인그레스 활성화 여부"
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

# Route53 관련 변수
variable "create_route53_record" {
  description = "Route53 레코드 생성 여부"
  type        = bool
  default     = true
}

variable "zone_id" {
  description = "Route53 호스팅 존 ID"
  type        = string
  default     = ""
}

variable "use_external_dns" {
  description = "External DNS를 사용하여 DNS 레코드를 관리할지 여부"
  type        = bool
  default     = false
}