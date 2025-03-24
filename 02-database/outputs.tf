#---------------------------------------
# 02단계: 데이터베이스 출력값
#---------------------------------------

output "db_instance_id" {
  description = "데이터베이스 인스턴스 ID"
  value       = module.db.db_instance_id
}

output "db_instance_address" {
  description = "데이터베이스 인스턴스 엔드포인트 주소"
  value       = module.db.db_instance_address
}

output "db_instance_port" {
  description = "데이터베이스 인스턴스 포트"
  value       = module.db.db_instance_port
  sensitive   = true
}

output "db_connection_info" {
  description = "데이터베이스 연결 정보 (애플리케이션용)"
  value       = module.db.db_connection_info
  sensitive   = true
}

output "db_subnet_group_id" {
  description = "데이터베이스 서브넷 그룹 ID"
  value       = module.db.db_subnet_group_id
}