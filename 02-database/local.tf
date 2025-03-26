#---------------------------------------
# 02단계: 로컬 변수 정의 - 모든 변수 값 지정 (최소 설정)
#---------------------------------------
locals {
  # 프로젝트 기본 설정
  project_name = "tier3"
  environment  = "dev"
  aws_region   = "ap-northeast-2"
  
  # 공통 태그
  common_tags = {
    Owner       = "DevOps"
    ManagedBy   = "Terraform"
    Project     = local.project_name
    Environment = local.environment
    Stage       = "02-Database"
  }
  
  # RDS 생성 제어 - true로 설정하면 생성, false로 설정하면 생성하지 않음
  create_rds = true
  
  # RDS 설정 - 실제 사용되는 값만 유지
  db_instance_class     = "db.t3.small"
  db_allocated_storage  = 20
  db_mysql_version      = "8.0.40"       # MySQL 엔진 버전
  db_storage_type       = "gp2"          # 표준 스토리지 타입
  db_multi_az           = false          # 단일 AZ 배포 (비용 절감)
  db_skip_final_snapshot = true          # 개발 환경에서는 true, 프로덕션에서는 false 권장
  db_backup_retention_period = 7         # 백업 보관 기간 (일)
  db_deletion_protection = false         # 삭제 방지 비활성화
  
  # 가용 영역 설정
  availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
  db_availability_zone_a = local.availability_zones[0]
  
  # 원격 상태 설정
  remote_state_bucket = "terraform-state-tier3-123456"
  remote_state_key_base = "tier3/01-base-infra/terraform.tfstate"
  remote_state_region = local.aws_region
}