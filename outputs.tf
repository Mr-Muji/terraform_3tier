# 네트워킹 모듈에서 중요한 출력값 노출
output "vpc_id" {
  description = "생성된 VPC ID"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "생성된 퍼블릭 서브넷 ID 목록"
  value       = module.networking.public_subnet_ids
}

output "nat_subnet_ids" {
  description = "생성된 NAT 서브넷 ID 목록"
  value       = module.networking.nat_subnet_ids
}

output "private_subnet_ids" {
  description = "생성된 프라이빗 서브넷 ID 목록"
  value       = module.networking.private_subnet_ids
}

#---------------------------------------
# 보안 그룹 출력값
# 다른 스크립트나 도구에서 참조할 수 있도록 중요 정보 출력
#---------------------------------------

# 웹 티어 보안 그룹 ID
output "web_security_group_id" {
  description = "웹 티어 보안 그룹 ID - 외부에서 참조하거나 문서화에 사용됩니다"
  value       = module.security.web_security_group_id
}

# 애플리케이션 티어 보안 그룹 ID
output "app_security_group_id" {
  description = "애플리케이션 티어 보안 그룹 ID - 외부에서 참조하거나 문서화에 사용됩니다"
  value       = module.security.app_security_group_id
}

# 데이터베이스 티어 보안 그룹 ID
output "db_security_group_id" {
  description = "데이터베이스 티어 보안 그룹 ID - 외부에서 참조하거나 문서화에 사용됩니다"
  value       = module.security.db_security_group_id
}

# 캐시 서비스 보안 그룹 ID
# output "cache_security_group_id" {
#   description = "캐시 서비스 보안 그룹 ID - Redis 또는 ElastiCache 설정에 사용됩니다"
#   value       = module.security.cache_security_group_id
# }

#---------------------------------------
# EKS 클러스터 출력값
#---------------------------------------
output "eks_cluster_id" {
  description = "EKS 클러스터 ID"
  value       = module.compute.cluster_id
}

output "eks_cluster_endpoint" {
  description = "쿠버네티스 API 서버 엔드포인트"
  value       = module.compute.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "클러스터 인증 기관 인증서 데이터"
  value       = module.compute.cluster_certificate_authority_data
  sensitive   = true
}