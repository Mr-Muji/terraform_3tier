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
  
  # 가용 영역 설정
  availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
  availability_zone_a = local.availability_zones[0]
  
  # 데이터베이스 설정 (최소 스펙)
  mysql_version     = "8.0.40"       # MySQL 엔진 버전
  db_instance_class = "db.t4g.micro" # ARM 기반 가장 저렴한 인스턴스
  allocated_storage = 5              # 최소 스토리지 크기 (GB)
  storage_type      = "gp2"          # 표준 스토리지 타입
  multi_az          = false          # 단일 AZ 배포 (비용 절감)
  
  # 백업 설정 (최소화)
  backup_retention_period = 0        # 백업 비활성화 (0일)
  
  # 보안 설정
  deletion_protection = false        # 삭제 방지 비활성화
  skip_final_snapshot = true         # 최종 스냅샷 생성 건너뛰기
  
  # 원격 상태 설정
  # 01-base-infra 상태 파일에서 정보 가져오기
  remote_state_backend = "s3"
  remote_state_key     = "tier3/01-base-infra/terraform.tfstate"
  remote_state_bucket  = "terraform-state-tier3-123456"
  remote_state_region  = "ap-northeast-2"
}