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
  default     = {
    "Azone" = "10.0.1.0/24",
    "Czone" = "10.0.2.0/24"
  }
}

variable "nat_subnet_cidrs" {
  description = "NAT 서브넷 CIDR 블록 맵"
  type        = map(string)
  default     = {
    "Azone" = "10.0.10.0/24",
    "Czone" = "10.0.20.0/24"
  }
}

variable "private_subnet_cidrs" {
  description = "프라이빗 서브넷 CIDR 블록 맵"
  type        = map(string)
  default     = {
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