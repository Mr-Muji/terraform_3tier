/**
 * IRSA(IAM Roles for Service Accounts) 모듈 출력값 정의 파일
 */

output "role_arn" {
  description = "생성된 IAM 역할 ARN"
  value       = aws_iam_role.eks_sa_role.arn
}

output "role_name" {
  description = "생성된 IAM 역할 이름"
  value       = aws_iam_role.eks_sa_role.name
}

output "service_account_name" {
  description = "서비스 계정 이름"
  value       = var.service_account_name
}