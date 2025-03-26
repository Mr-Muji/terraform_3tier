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

output "github_token" {
  description = "GitHub 접근 토큰"
  value       = jsondecode(aws_secretsmanager_secret_version.github.secret_string)["token"]
  sensitive   = true
}

output "github_token_secret_arn" {
  description = "GitHub 토큰 시크릿 ARN"
  value       = aws_secretsmanager_secret.github.arn
}

# Jenkins 관련 출력값 추가
output "jenkins_admin_password" {
  description = "Jenkins 관리자 비밀번호"
  value       = var.jenkins_admin_password != "" ? jsondecode(aws_secretsmanager_secret_version.jenkins.secret_string)["admin_password"] : ""
  sensitive   = true
}

output "jenkins_secret_arn" {
  description = "Jenkins 시크릿 ARN"
  value       = aws_secretsmanager_secret.jenkins.arn
}

output "aws_access_key" {
  description = "AWS 접근 키 (Jenkins 파이프라인용)"
  value       = var.aws_access_key != "" ? jsondecode(aws_secretsmanager_secret_version.jenkins.secret_string)["aws_access_key"] : ""
  sensitive   = true
}

output "aws_secret_key" {
  description = "AWS 시크릿 키 (Jenkins 파이프라인용)" 
  value       = var.aws_secret_key != "" ? jsondecode(aws_secretsmanager_secret_version.jenkins.secret_string)["aws_secret_key"] : ""
  sensitive   = true
}

output "dockerhub_username" {
  description = "Docker Hub 사용자명"
  value       = var.dockerhub_username != "" ? jsondecode(aws_secretsmanager_secret_version.jenkins.secret_string)["dockerhub_username"] : ""
  sensitive   = true
}

output "dockerhub_password" {
  description = "Docker Hub 비밀번호"
  value       = var.dockerhub_password != "" ? jsondecode(aws_secretsmanager_secret_version.jenkins.secret_string)["dockerhub_password"] : ""
  sensitive   = true
}