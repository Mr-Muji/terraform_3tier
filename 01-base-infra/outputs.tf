#---------------------------------------
# 네트워킹 모듈 출력
#---------------------------------------
output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "VPC의 CIDR 블록"
  value       = module.networking.vpc_cidr
}

output "public_subnet_ids" {
  description = "퍼블릭 서브넷 ID 목록"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "프라이빗 서브넷 ID 목록 (애플리케이션용)"
  value       = module.networking.private_subnet_ids
}

output "database_subnet_ids" {
  description = "데이터베이스 서브넷 ID 목록"
  value       = module.networking.database_subnet_ids
}

output "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 블록 맵"
  value       = local.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  description = "프라이빗 서브넷 CIDR 블록 맵 (애플리케이션용)"
  value       = local.private_subnet_cidrs
}

output "database_subnet_cidrs" {
  description = "데이터베이스 서브넷 CIDR 블록 맵"
  value       = local.database_subnet_cidrs
}

output "public_route_table_id" {
  description = "퍼블릭 라우팅 테이블 ID"
  value       = module.networking.public_route_table_id
}

output "private_route_table_ids" {
  description = "프라이빗 라우팅 테이블 ID 목록"
  value       = module.networking.private_route_table_ids
}

output "database_route_table_ids" {
  description = "데이터베이스 라우팅 테이블 ID 목록"
  value       = module.networking.database_route_table_ids
}

output "nat_gateway_ids" {
  description = "NAT 게이트웨이 ID 목록"
  value       = module.networking.nat_gateway_ids
}

#---------------------------------------
# 보안 모듈 출력
#---------------------------------------
output "app_security_group_id" {
  description = "애플리케이션 계층 보안 그룹 ID"
  value       = module.security.app_security_group_id
}

output "alb_security_group_id" {
  description = "ALB 보안 그룹 ID"
  value       = module.security.alb_security_group_id
}

output "database_security_group_id" {
  description = "데이터베이스 보안 그룹 ID"
  value       = module.security.database_security_group_id
}

#---------------------------------------
# Secrets 모듈 출력
#---------------------------------------
output "mysql_secret_arn" {
  description = "MySQL 시크릿 ARN"
  value       = module.secrets.mysql_secret_arn
}

output "secrets_access_policy_arn" {
  description = "시크릿 접근 정책 ARN"
  value       = module.secrets.secrets_access_policy_arn
}

# GitHub 토큰 관련 출력 - 토큰 자체는 출력하지 않고 ARN만 출력
output "github_token_secret_arn" {
  description = "GitHub 토큰 시크릿 ARN"
  value       = module.secrets.github_token_secret_arn
}

# Jenkins 시크릿 관련 출력
output "jenkins_secret_arn" {
  description = "Jenkins 시크릿 ARN"
  value       = module.secrets.jenkins_secret_arn
}

output "jenkins_admin_password" {
  description = "Jenkins 관리자 비밀번호"
  value       = module.secrets.jenkins_admin_password
  sensitive   = true
}

#---------------------------------------
# Route53 호스팅 영역 출력 (선택적)
#---------------------------------------
output "route53_zone_id" {
  description = "Route53 호스팅 영역 ID"
  value       = local.domain_name != "" ? data.aws_route53_zone.main[0].zone_id : null
}

output "domain_name" {
  description = "도메인 이름"
  value       = local.domain_name
}

#---------------------------------------
# 환경 설정 출력
#---------------------------------------
output "project_name" {
  description = "프로젝트 이름"
  value       = local.project_name
}

output "environment" {
  description = "환경 설정"
  value       = local.environment
}

output "aws_region" {
  description = "AWS 리전"
  value       = local.aws_region
}
