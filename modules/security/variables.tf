# VPC ID - 보안 그룹을 생성할 VPC의 식별자
variable "vpc_id" {
  description = "보안 그룹이 생성될 VPC ID"
  type        = string
}

# 프로젝트 이름 - 리소스 이름 지정 및 태그 지정에 사용
variable "project_name" {
  description = "프로젝트 이름 - 모든 리소스 이름의 접두사로 사용됩니다"
  type        = string
}

# 환경 설정 - 개발, 스테이징, 프로덕션 환경 구분에 사용
variable "environment" {
  description = "배포 환경 (dev, staging, prod) - 리소스 태그 지정에 사용됩니다"
  type        = string
}

# VPC CIDR 블록 - 보안 그룹 규칙에서 참조할 수 있음
variable "vpc_cidr" {
  description = "VPC CIDR 블록 - 내부 통신 규칙 정의에 사용될 수 있습니다"
  type        = string
}

# 퍼블릭 서브넷 ID 목록 - 로드 밸런서 등의 배포에 사용
variable "public_subnet_ids" {
  description = "퍼블릭 서브넷 ID 목록 - ALB 및 외부 리소스 배포에 사용됩니다"
  type        = list(string)
}

# NAT 서브넷 ID 목록 - 애플리케이션 계층 배포에 사용
variable "nat_subnet_ids" {
  description = "NAT 서브넷 ID 목록 - 애플리케이션 리소스 배포에 사용됩니다"
  type        = list(string)
}

# 프라이빗 서브넷 ID 목록 - 데이터베이스 등 배포에 사용
variable "private_subnet_ids" {
  description = "프라이빗 서브넷 ID 목록 - 데이터베이스 및 내부 리소스 배포에 사용됩니다"
  type        = list(string)
}

# EKS 클러스터 이름 - 태그 지정 및 보안 그룹 규칙에 사용
variable "eks_cluster_name" {
  description = "EKS 클러스터 이름 - 클러스터 관련 리소스 식별에 사용됩니다"
  type        = string
  default     = null  # 기본값은 null로 설정 (선택적 변수)
}