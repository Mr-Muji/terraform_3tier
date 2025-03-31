output "vpc_id" {
  description = "Access VPC ID"
  value       = module.access_vpc.vpc_id
}

output "vpc_cidr" {
  description = "Access VPC CIDR 블록"
  value       = module.access_vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "퍼블릭 서브넷 ID 목록"
  value       = module.access_vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "프라이빗 서브넷 ID 목록"
  value       = module.access_vpc.private_subnet_ids
}

output "public_route_table_id" {
  description = "퍼블릭 라우트 테이블 ID"
  value       = module.access_vpc.public_route_table_id
}

output "private_route_table_ids" {
  description = "프라이빗 라우트 테이블 ID 목록"
  value       = module.access_vpc.private_route_table_ids
}