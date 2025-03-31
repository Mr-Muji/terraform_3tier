#---------------------------------------
# 로컬 변수 정의
#---------------------------------------
locals {
  # 프로젝트 기본 설정
  project_name = "tier3"
  environment  = "dev"
  aws_region   = "ap-northeast-2"
  
  # 공통 태그
  common_tags = {
    Owner       = "DevOps"
    ManagedBy   = "Terraform"
    Project     = local.project_name
    Environment = local.environment
    Stage       = "VPC-Connection"
  }

 
  # 액세스 VPC 설정 (11번에서 옮겨옴)
  access_vpc_name = "access"
  access_vpc_cidr = "10.10.0.0/16"  # Access VPC CIDR
  
  # 가용영역 설정
  azs = ["ap-northeast-2a", "ap-northeast-2c"]
  
  # 액세스 VPC 서브넷 CIDR 설정
  access_public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
  access_private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]
} 