#---------------------------------------
# 네트워킹 모듈 호출
# VPC, 서브넷, 라우팅 테이블 등 기본 네트워크 인프라 생성
#---------------------------------------
module "networking" {
  source = "../modules/networking"

  # common 모듈에서 가져온 값 사용
  project_name = data.terraform_remote_state.common.outputs.project_name  # 이미 local.tf에서 common 출력값을 사용
  environment  = data.terraform_remote_state.common.outputs.environment   # 이미 local.tf에서 common 출력값을 사용
  vpc_cidr     = data.terraform_remote_state.common.outputs.vpc_cidr

  # 기타 설정은 local.tf에서 가져옴
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

  vpc_id   = module.networking.vpc_id 
  vpc_cidr = local.vpc_cidr

  # common 모듈에서 가져온 값은 local.tf에서 이미 처리
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
  
  # 데이터베이스 정보
  db_username = var.db_username
  db_password = var.db_password
  db_name     = var.db_name
  
  # GitHub 토큰 추가
  github_token = var.github_token
  
  # Jenkins 관련 시크릿 추가
  jenkins_admin_password = var.jenkins_admin_password
  aws_access_key         = var.aws_access_key
  aws_secret_key         = var.aws_secret_key
  dockerhub_username     = var.dockerhub_username
  dockerhub_password     = var.dockerhub_password

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
