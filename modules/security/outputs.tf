# 각 보안 그룹 ID 출력
output "app_security_group_id" {
  description = "애플리케이션 계층 보안 그룹 ID"
  value       = aws_security_group.app_sg.id
}

output "alb_security_group_id" {
  description = "ALB 보안 그룹 ID"
  value       = aws_security_group.alb_sg.id
}

output "database_security_group_id" {
  description = "데이터베이스 보안 그룹 ID"
  value       = aws_security_group.database_sg.id
}