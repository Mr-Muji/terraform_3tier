# VPC 출력값
output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = aws_vpc.vpc_tier3.id
}

output "vpc_cidr" {
  description = "VPC의 CIDR 블록"
  value       = aws_vpc.vpc_tier3.cidr_block
}

# 서브넷 출력값
output "public_subnet_ids" {
  description = "생성된 퍼블릭 서브넷 ID 목록"
  value       = [aws_subnet.subnet_public_azone.id, aws_subnet.subnet_public_czone.id]
}

output "private_subnet_ids" {
  description = "생성된 프라이빗 서브넷 ID 목록"
  value       = [aws_subnet.subnet_private_azone.id, aws_subnet.subnet_private_czone.id]
}

# 데이터베이스 서브넷 ID 목록 출력 (기존 프라이빗 서브넷)
output "database_subnet_ids" {
  description = "생성된 데이터베이스 서브넷 ID 목록"
  value       = [aws_subnet.subnet_database_azone.id, aws_subnet.subnet_database_czone.id]
}

# 이전 NAT 서브넷 ID 출력 유지 (이전 코드와의 호환성)
output "nat_subnet_ids" {
  description = "생성된 프라이빗 서브넷 ID 목록 (이전 NAT 서브넷)"
  value       = [aws_subnet.subnet_private_azone.id, aws_subnet.subnet_private_czone.id]
}

# 개별 서브넷 ID 출력값
output "public_subnet_a_id" {
  description = "퍼블릭 서브넷 A ID"
  value       = aws_subnet.subnet_public_azone.id
}

output "public_subnet_c_id" {
  description = "퍼블릭 서브넷 C ID"
  value       = aws_subnet.subnet_public_czone.id
}

output "nat_subnet_a_id" {
  description = "NAT 서브넷 A ID"
  value       = aws_subnet.subnet_private_azone.id
}

output "nat_subnet_c_id" {
  description = "NAT 서브넷 C ID"
  value       = aws_subnet.subnet_private_czone.id
}

output "private_subnet_a_id" {
  description = "프라이빗 서브넷 A ID"
  value       = aws_subnet.subnet_private_azone.id
}

output "private_subnet_c_id" {
  description = "프라이빗 서브넷 C ID"
  value       = aws_subnet.subnet_private_czone.id
}

# 게이트웨이 출력값
output "internet_gateway_id" {
  description = "인터넷 게이트웨이 ID"
  value       = aws_internet_gateway.igw_tier3.id
}

# 수정된 코드 (단일 NAT 게이트웨이)
output "nat_gateway_id" {
  description = "NAT 게이트웨이 ID"
  value       = aws_nat_gateway.nat_gateway.id
}

# 라우팅 테이블 출력값
output "private_route_table_id" {
  description = "프라이빗 라우팅 테이블 ID"
  value       = aws_route_table.rt_private.id
}

# DB 서브넷 그룹 출력값
output "db_subnet_group_name" {
  description = "데이터베이스 서브넷 그룹 이름"
  value       = aws_db_subnet_group.db_subnet_group.name
}

output "db_subnet_group_id" {
  description = "데이터베이스 서브넷 그룹 ID"
  value       = aws_db_subnet_group.db_subnet_group.id
}