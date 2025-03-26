#---------------------------------------
# 02단계: 데이터베이스 출력값
#---------------------------------------

# RDS 데이터베이스 출력
output "db_instance_endpoint" {
  description = "데이터베이스 엔드포인트 주소"
  value       = local.create_rds ? module.db[0].db_instance_address : null
}

output "db_instance_name" {
  description = "RDS 데이터베이스 이름"
  value       = local.create_rds ? module.db[0].db_instance_name : null
  sensitive   = true
}

output "db_instance_id" {
  description = "RDS 인스턴스 ID"
  value       = local.create_rds ? module.db[0].db_instance_id : null
}

output "db_instance_arn" {
  description = "데이터베이스 ARN"
  value       = local.create_rds ? module.db[0].db_instance_resource_id : null
}

output "db_security_group_id" {
  description = "RDS 보안 그룹 ID"
  value       = local.create_rds ? module.db[0].db_security_group_id : null
}