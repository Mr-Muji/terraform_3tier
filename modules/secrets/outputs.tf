/**
 * AWS Secrets Manager 모듈의 출력값 정의 파일
 */

output "mysql_secret_arn" {
  description = "MySQL 데이터베이스 시크릿 ARN"
  value       = aws_secretsmanager_secret.mysql.arn
}

output "mysql_secret_id" {
  description = "MySQL 데이터베이스 시크릿 ID"
  value       = aws_secretsmanager_secret.mysql.id
}

output "secrets_kms_key_arn" {
  description = "시크릿 암호화를 위한 KMS 키 ARN"
  value       = aws_kms_key.secrets.arn
}

output "secrets_access_policy_arn" {
  description = "시크릿 접근 IAM 정책 ARN"
  value       = aws_iam_policy.secrets_access.arn
}

output "db_username" {
  description = "데이터베이스 사용자 이름"
  value       = jsondecode(aws_secretsmanager_secret_version.mysql.secret_string)["username"]
  sensitive   = true
}

output "db_password" {
  description = "데이터베이스 비밀번호"
  value       = jsondecode(aws_secretsmanager_secret_version.mysql.secret_string)["password"]
  sensitive   = true
}

output "db_name" {
  description = "데이터베이스 이름"
  value       = jsondecode(aws_secretsmanager_secret_version.mysql.secret_string)["dbname"]
}