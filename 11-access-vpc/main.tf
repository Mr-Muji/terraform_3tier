#---------------------------------------
# Access VPC 생성
#---------------------------------------
module "access_vpc" {
  source = "../modules/access-vpc"

  # 프로젝트 정보
  project_name = local.project_name
  environment  = local.environment
  vpc_name     = local.vpc_name
  
  # VPC 설정
  vpc_cidr = local.vpc_cidr
  azs      = local.azs
  
  # 서브넷 설정
  public_subnet_cidrs  = local.public_subnet_cidrs
  private_subnet_cidrs = local.private_subnet_cidrs
  
  # NAT Gateway 설정
  enable_nat_gateway  = false  # Access VPC는 NAT Gateway 불필요
  single_nat_gateway  = false
  
  # 태그
  common_tags = local.common_tags
} 