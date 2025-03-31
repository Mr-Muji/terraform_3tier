variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "환경 (dev, prod 등)"
  type        = string
}

variable "vpc_name" {
  description = "VPC 이름 (예: main, mgmt, shared 등)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "azs" {
  description = "가용영역 목록"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 블록 목록"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "프라이빗 서브넷 CIDR 블록 목록"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "NAT 게이트웨이 생성 여부"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "단일 NAT 게이트웨이 사용 여부 (비용 절감용)"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "모든 리소스에 적용할 공통 태그"
  type        = map(string)
  default     = {}
} 