#---------------------------------------
# 네트워킹 모듈 호출
# VPC, 서브넷, 라우팅 테이블 등 기본 네트워크 인프라 생성
#---------------------------------------
module "networking" {
  source = "../modules/networking"

  # locals에서 변수 전달
  project_name           = local.project_name
  environment            = local.environment
  vpc_cidr               = local.vpc_cidr
  availability_zones     = local.availability_zones
  public_subnet_cidrs    = local.public_subnet_cidrs
  private_subnet_cidrs   = local.private_subnet_cidrs
  database_subnet_cidrs  = local.database_subnet_cidrs
  enable_dns_support     = local.enable_dns_support
  enable_dns_hostnames   = local.enable_dns_hostnames
  eks_cluster_name       = local.eks_cluster_name
}

#---------------------------------------
# 보안 모듈 호출
# 보안 그룹, IAM 역할 등 보안 관련 리소스 생성
#---------------------------------------
module "security" {
  source = "../modules/security"

  # 네트워킹 모듈에서 출력된 값 전달
  vpc_id   = module.networking.vpc_id 
  vpc_cidr = local.vpc_cidr

  # locals에서 변수 전달
  project_name = local.project_name
  environment  = local.environment

  # 서브넷 ID 전달 - 리소스 배치에 사용됨
  public_subnet_ids    = module.networking.public_subnet_ids
  private_subnet_ids   = module.networking.private_subnet_ids
  database_subnet_ids  = module.networking.database_subnet_ids

  # EKS 관련 설정
  eks_cluster_name = local.eks_cluster_name

  # 네트워킹 모듈에 의존성 추가
  depends_on = [
    module.networking
  ]
}

#---------------------------------------
# Secrets Manager 모듈 호출
# 데이터베이스 보안 정보 관리
#---------------------------------------
module "secrets" {
  source = "../modules/secrets"

  prefix      = local.project_name
  common_tags = local.common_tags

  # 민감 정보
  db_username = var.db_username
  db_password = var.db_password
  db_name     = var.db_name

  # 네트워킹 모듈에 의존성 추가
  depends_on = [
    module.networking
  ]
}

# 기존 Route 53 호스팅 영역 데이터 소스로 가져오기 (선택적)
data "aws_route53_zone" "main" {
  count = local.domain_name != "" ? 1 : 0
  name = local.domain_name
}
