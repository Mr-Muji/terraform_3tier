/**
 * MySQL DB 모듈에 필요한 변수 정의 파일 (Secrets Manager 사용 버전)
 */

variable "prefix" {
  description = "리소스 이름에 사용할 접두사"
  type        = string
}

variable "common_tags" {
  description = "모든 리소스에 적용할 공통 태그"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "데이터베이스가 배포될 VPC ID"
  type        = string
}

# 서브넷 ID 목록
variable "subnet_ids" {
  description = "DB가 배포될 서브넷 ID 목록"
  type        = list(string)
}

variable "eks_node_security_group_id" {
  description = "EKS 노드 보안 그룹 ID (데이터베이스 접근 허용)"
  type        = string
}

# Secrets Manager에서 가져올 시크릿 ARN
variable "mysql_secret_arn" {
  description = "MySQL 데이터베이스 자격 증명이 저장된 Secrets Manager 시크릿 ARN"
  type        = string
}

variable "mysql_version" {
  description = "MySQL 엔진 버전"
  type        = string
  default     = "8.0.40"
}

variable "db_instance_class" {
  description = "데이터베이스 인스턴스 유형"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "할당할 스토리지 용량 (GB)"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "스토리지 유형 (gp2, gp3, io1 등)"
  type        = string
  default     = "gp3"
}

variable "multi_az" {
  description = "다중 AZ 배포 여부 (고가용성)"
  type        = bool
  default     = false  # A존에만 배포하므로 기본값 false
}

variable "backup_retention_period" {
  description = "자동 백업 보존 기간 (일)"
  type        = number
  default     = 1
}

variable "deletion_protection" {
  description = "삭제 방지 활성화 여부"
  type        = bool
  default     = false # 삭제 방지 비활성화
}

variable "skip_final_snapshot" {
  description = "삭제 시 최종 스냅샷 생성 건너뛰기 여부"
  type        = bool
  default     = false
}

variable "availability_zone_a" {
  description = "A존 가용 영역 (예: ap-northeast-2a)"
  type        = string
}