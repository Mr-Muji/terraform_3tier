# 리전 설정
variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

# 프로젝트 이름
variable "project_name" {
  description = "프로젝트 이름"
  type        = string
  default     = "tier3"
}

# 환경 설정 (dev, staging, prod)
variable "environment" {
  description = "배포 환경"
  type        = string
  default     = "dev"
}

# VPC CIDR 블록
variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.0.0.0/16"
}

# 가용 영역 설정
variable "availability_zones" {
  description = "사용할 가용 영역 목록"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

# 서브넷 CIDR 블록
variable "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 블록 맵"
  type        = map(string)
  default = {
    "Azone" = "10.0.1.0/24",
    "Czone" = "10.0.2.0/24"
  }
}

variable "nat_subnet_cidrs" {
  description = "NAT 서브넷 CIDR 블록 맵"
  type        = map(string)
  default = {
    "Azone" = "10.0.10.0/24",
    "Czone" = "10.0.20.0/24"
  }
}

variable "private_subnet_cidrs" {
  description = "프라이빗 서브넷 CIDR 블록 맵"
  type        = map(string)
  default = {
    "Azone" = "10.0.100.0/24",
    "Czone" = "10.0.200.0/24"
  }
}

# DNS 설정
variable "enable_dns_support" {
  description = "VPC에서 DNS 지원 활성화 여부"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "VPC에서 DNS 호스트 이름 활성화 여부"
  type        = bool
  default     = true
}

#---------------------------------------
# EKS 클러스터 설정 변수
#---------------------------------------
variable "eks_cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
  default     = "eks-cluster"
}

variable "kubernetes_version" {
  description = "EKS 클러스터에 사용할 쿠버네티스 버전"
  type        = string
  default     = "1.31"
}

variable "enabled_cluster_log_types" {
  description = "EKS 클러스터에서 활성화할 로그 유형"
  type        = list(string)
  default     = ["api", "audit"] # 필요에 따라 조정
}

variable "public_access_cidrs" {
  description = "EKS API 서버에 공개적으로 접근할 수 있는 CIDR 블록"
  type        = list(string)
  default     = ["0.0.0.0/0"] # 보안을 위해 필요한 IP 범위로 제한하는 것이 좋습니다
}

variable "common_tags" {
  description = "모든 리소스에 적용할 공통 태그"
  type        = map(string)
  default     = {}
}

# 노드 그룹 설정
variable "node_instance_types" {
  description = "EKS 노드 그룹에 사용할 인스턴스 타입 목록"
  type        = list(string)
  default     = ["t2.micro"]
}

variable "node_disk_size" {
  description = "EKS 노드의 디스크 크기(GB)"
  type        = number
  default     = 8
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