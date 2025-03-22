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

# VPC CIDR 블록
variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

# 가용 영역 설정
variable "availability_zones" {
  description = "사용할 가용 영역 목록"
  type        = list(string)
}

# 서브넷 CIDR 블록
variable "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 블록 맵"
  type        = map(string)
}

# NAT 서브넷 CIDR 블록
variable "nat_subnet_cidrs" {
  description = "프라이빗 서브넷의 CIDR 블록 (이전 NAT 서브넷, 앱 계층용)"
  type        = map(string)
}

# 프라이빗 서브넷 CIDR 블록
variable "private_subnet_cidrs" {
  description = "데이터베이스 서브넷의 CIDR 블록 (이전 프라이빗 서브넷, 데이터베이스 계층용)"
  type        = map(string)
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

# EKS 클러스터 이름
variable "eks_cluster_name" {
  description = "EKS 클러스터 이름 - 서브넷 태그 지정에 사용"
  type        = string
}