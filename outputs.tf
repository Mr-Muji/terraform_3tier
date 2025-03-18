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