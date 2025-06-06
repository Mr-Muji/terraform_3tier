#---------------------------------------
# 02단계: 데이터베이스 리소스 배포
# 01단계에서 생성된 인프라를 기반으로 데이터베이스 구성
#---------------------------------------


#---------------------------------------
# 데이터베이스 모듈 호출
#---------------------------------------
module "db" {
  source = "../modules/db"

  # RDS 생성 제어
  count = local.create_rds ? 1 : 0
  
  # 기본 설정
  prefix      = local.project_name
  common_tags = local.common_tags
  
  # 네트워킹 정보 (01단계 상태에서 가져옴)
  vpc_id                     = data.terraform_remote_state.base_infra.outputs.vpc_id
  subnet_ids                 = data.terraform_remote_state.base_infra.outputs.private_subnet_ids
  eks_node_security_group_id = data.terraform_remote_state.base_infra.outputs.app_security_group_id
  
  # Secrets Manager ARN (01단계 상태에서 가져옴)
  mysql_secret_arn = data.terraform_remote_state.base_infra.outputs.mysql_secret_arn
  
  # 데이터베이스 설정 (local.tf에서 정의한 값 사용)
  mysql_version           = local.db_mysql_version
  db_instance_class       = local.db_instance_class
  allocated_storage       = local.db_allocated_storage
  storage_type            = local.db_storage_type
  multi_az                = local.db_multi_az
  backup_retention_period = local.db_backup_retention_period
  deletion_protection     = local.db_deletion_protection
  skip_final_snapshot     = local.db_skip_final_snapshot
  availability_zone_a     = local.db_availability_zone_a
}