#---------------------------------------
# 보안 그룹 출력값
# 다른 모듈에서 이 보안 그룹을 참조할 수 있도록 ID를 출력합니다
#---------------------------------------

# 웹 티어 보안 그룹 ID
output "web_security_group_id" {
  description = "웹 티어 보안 그룹 ID - ALB 및 웹 서버에 연결하는 데 사용됩니다"
  value       = aws_security_group.web_sg.id
}

# 애플리케이션 티어 보안 그룹 ID
output "app_security_group_id" {
  description = "애플리케이션 티어 보안 그룹 ID - EKS 노드 및 애플리케이션 서버에 연결하는 데 사용됩니다"
  value       = aws_security_group.app_sg.id
}

# 데이터베이스 티어 보안 그룹 ID
output "db_security_group_id" {
  description = "데이터베이스 티어 보안 그룹 ID - RDS 및 기타 데이터베이스 서비스에 연결하는 데 사용됩니다"
  value       = aws_security_group.db_sg.id
}

# 캐시 보안 그룹 ID
# output "cache_security_group_id" {
#   description = "캐시 서비스 보안 그룹 ID - Redis 및 ElastiCache에 연결하는 데 사용됩니다"
#   value       = aws_security_group.cache_sg.id
# }
