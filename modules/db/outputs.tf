/**
 * MySQL DB 모듈의 출력값 정의 파일
 * 다른 모듈이나 메인 구성에서 참조할 수 있는 출력값을 정의합니다.
 */

output "db_instance_id" {
  description = "생성된 RDS 인스턴스의 ID"
  value       = aws_db_instance.mysql.id
}

output "db_instance_address" {
  description = "RDS 인스턴스의 엔드포인트 주소"
  value       = aws_db_instance.mysql.address
}

output "db_instance_endpoint" {
  description = "RDS 인스턴스의 연결 엔드포인트 (주소:포트)"
  value       = aws_db_instance.mysql.endpoint
}

output "db_instance_name" {
  description = "데이터베이스 이름"
  value       = aws_db_instance.mysql.db_name
}

output "db_subnet_group_id" {
  description = "생성된 DB 서브넷 그룹 ID"
  value       = aws_db_subnet_group.mysql.id
}

output "db_security_group_id" {
  description = "데이터베이스 보안 그룹 ID"
  value       = aws_security_group.mysql.id
}

output "db_parameter_group_id" {
  description = "데이터베이스 파라미터 그룹 ID"
  value       = aws_db_parameter_group.mysql.id
}

output "db_instance_resource_id" {
  description = "RDS 인스턴스의 리소스 ID"
  value       = aws_db_instance.mysql.resource_id
}

output "db_instance_status" {
  description = "RDS 인스턴스의 현재 상태"
  value       = aws_db_instance.mysql.status
}

output "db_instance_availability_zone" {
  description = "RDS 인스턴스의 가용 영역"
  value       = aws_db_instance.mysql.availability_zone
}