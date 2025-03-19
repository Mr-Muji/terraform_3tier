# 프로젝트 이름
variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

# 환경 설정
variable "environment" {
  description = "배포 환경 (dev, staging, prod)"
  type        = string
}

# EKS 클러스터 이름
variable "eks_cluster_name" {
  description = "생성할 EKS 클러스터의 이름"
  type        = string
}

# VPC ID
variable "vpc_id" {
  description = "EKS 클러스터가 생성될 VPC의 ID"
  type        = string
}

# 서브넷 ID 목록
variable "subnet_ids" {
  description = "EKS 클러스터와 노드 그룹이 배포될 서브넷 ID 목록"
  type        = list(string)
}

# 쿠버네티스 버전
variable "kubernetes_version" {
  description = "사용할 쿠버네티스 버전"
  type        = string
  default     = "1.31"
}
# 엔드포인트 접근 설정
variable "endpoint_private_access" {
  description = "VPC 내부에서 API 서버 엔드포인트 접근 활성화 여부"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "인터넷에서 API 서버 엔드포인트 접근 활성화 여부"
  type        = bool
  default     = true
}

# 퍼블릭 엔드포인트 접근 제한
variable "public_access_cidrs" {
  description = "EKS 클러스터 API 서버 엔드포인트에 공개적으로 접근할 수 있는 CIDR 블록"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# 보안 그룹
variable "additional_security_group_ids" {
  description = "클러스터에 연결할 추가 보안 그룹 ID 목록"
  type        = list(string)
  default     = []
}

# CloudWatch 관찰성 활성화 여부
variable "enable_cloudwatch_observability" {
  description = "CloudWatch 관찰성 애드온 활성화 여부"
  type        = bool
  default     = true
}

# 클러스터 로그 유형
variable "enabled_cluster_log_types" {
  description = "EKS 클러스터에서 활성화할 로그 유형"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

# 태그
variable "tags" {
  description = "모든 리소스에 적용할 추가 태그"
  type        = map(string)
  default     = {}
}

# 노드 그룹 관련 변수
variable "node_instance_types" {
  description = "EKS 노드 그룹에 사용할 인스턴스 타입 목록"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_disk_size" {
  description = "EKS 노드의 디스크 크기(GB)"
  type        = number
  default     = 20
}

variable "node_capacity_type" {
  description = "EKS 노드 용량 타입 (ON_DEMAND 또는 SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_desired_size" {
  description = "EKS 노드 그룹의 원하는 노드 수"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "EKS 노드 그룹의 최소 노드 수"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "EKS 노드 그룹의 최대 노드 수"
  type        = number
  default     = 5
}