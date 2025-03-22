#---------------------------------------
# 네트워킹 모듈 호출
# VPC, 서브넷, 라우팅 테이블 등 기본 네트워크 인프라 생성
#---------------------------------------

# 로컬 변수 정의
locals {
  common_tags = var.common_tags
}

module "networking" {
  source = "./modules/networking"

  # 기본 변수 전달
  project_name         = var.project_name         # 프로젝트 이름 (예: "tier3")
  environment          = var.environment          # 배포 환경 (예: "dev", "staging", "prod")
  vpc_cidr             = var.vpc_cidr             # VPC CIDR 블록 (예: "10.0.0.0/16")
  availability_zones   = var.availability_zones   # 사용할 가용 영역 목록 (예: ["ap-northeast-2a", "ap-northeast-2c"])
  public_subnet_cidrs  = var.public_subnet_cidrs  # 퍼블릭 서브넷 CIDR 블록 맵 (예: {"Azone"="10.0.1.0/24", "Czone"="10.0.2.0/24"})
  nat_subnet_cidrs     = var.nat_subnet_cidrs     # NAT 서브넷 CIDR 블록 맵 (예: {"Azone"="10.0.10.0/24", "Czone"="10.0.20.0/24"})
  private_subnet_cidrs = var.private_subnet_cidrs # 프라이빗 서브넷 CIDR 블록 맵 (예: {"Azone"="10.0.100.0/24", "Czone"="10.0.200.0/24"})
  enable_dns_support   = var.enable_dns_support   # VPC에서 DNS 지원 활성화 여부 (기본값: true)
  enable_dns_hostnames = var.enable_dns_hostnames # VPC에서 DNS 호스트 이름 활성화 여부 (기본값: true)
  eks_cluster_name     = var.eks_cluster_name
}

#---------------------------------------
# 보안 모듈 호출
# 보안 그룹, IAM 역할 등 보안 관련 리소스 생성
#---------------------------------------
module "security" {
  source = "./modules/security"

  # 네트워킹 모듈에서 출력된 값 전달
  vpc_id   = module.networking.vpc_id # VPC ID
  vpc_cidr = var.vpc_cidr             # VPC CIDR 블록

  # 기본 변수 전달
  project_name = var.project_name # 프로젝트 이름
  environment  = var.environment  # 환경 (dev, staging, prod)

  # 서브넷 ID 전달 - 리소스 배치에 사용됨
  public_subnet_ids  = module.networking.public_subnet_ids  # 퍼블릭 서브넷 ID 목록
  nat_subnet_ids     = module.networking.nat_subnet_ids     # NAT 서브넷 ID 목록
  private_subnet_ids = module.networking.private_subnet_ids # 프라이빗 서브넷 ID 목록

  # EKS 관련 설정
  eks_cluster_name = var.eks_cluster_name # EKS 클러스터 이름
}

#---------------------------------------
# Compute 모듈 호출 (EKS 클러스터)
# 애플리케이션 계층을 위한 쿠버네티스 클러스터 생성
#---------------------------------------
module "compute" {
  source = "./modules/compute"

  project_name     = var.project_name
  environment      = var.environment
  eks_cluster_name = var.eks_cluster_name

  # 네트워킹 모듈에서 출력된 값 사용
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.nat_subnet_ids

  # 보안 모듈에서 출력된 값 사용
  additional_security_group_ids = [module.security.app_security_group_id]

  # 노드 그룹 설정
  node_instance_types = ["t3.medium"]
  node_disk_size      = 20
  node_capacity_type  = "ON_DEMAND"
  node_desired_size   = 1
  node_min_size       = 1
  node_max_size       = 2

  # 엔드포인트 접근 설정
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = var.public_access_cidrs

  # 클러스터 버전 및 설정
  kubernetes_version        = var.kubernetes_version
  enabled_cluster_log_types = var.enabled_cluster_log_types
  # public_access_cidrs = var.public_access_cidrs

  # 추가 태그
  tags = var.common_tags
}

#---------------------------------------
# 프론트엔드 모듈 호출
# 프론트엔드 웹 애플리케이션을 위한 S3 버킷 및 CloudFront 배포 생성
#---------------------------------------

# # 기존 Route 53 호스팅 영역 데이터 소스로 가져오기
# data "aws_route53_zone" "main" {
#   name = "mydairy.my"
# }

# # 프론트엔드 모듈 호출
# module "frontend" {
#   source = "./modules/frontend"

#   environment     = var.environment
#   project_name    = var.project_name
#   domain_name     = "mydairy.my"
#   zone_id         = data.aws_route53_zone.main.zone_id
#   certificate_arn = "arn:aws:acm:us-east-1:183631327456:certificate/f7e962fb-4afa-446b-9b04-8c4e330a142b"
#   # CloudFront 배포에 사용되는 인증서는 반드시 버지니아 북부 리전인 us-east-1에 있어야 함
# }

#---------------------------------------
# Secrets Manager 모듈 호출
# 데이터베이스 보안 정보 관리
#---------------------------------------
module "secrets" {
  source = "./modules/secrets"

  prefix      = var.project_name
  common_tags = local.common_tags

  # 민감 정보 (환경 변수에서 가져오거나 다른 안전한 방법으로 제공)
  db_username = var.db_username
  db_password = var.db_password
  db_name     = var.db_name

  # EKS 노드에 시크릿 접근 권한 부여
  # node_role_arn = module.compute.node_role_arn # 노드 역할 ARN 사용
}

#---------------------------------------
# DB 모듈 호출
# 데이터베이스 인스턴스 생성
#---------------------------------------
module "db" {
  source = "./modules/db"

  # Secrets Manager 모듈에 의존성 추가 (시크릿 생성 후 DB 생성)
  depends_on = [module.secrets]

  prefix                     = var.project_name
  common_tags                = local.common_tags
  vpc_id                     = module.networking.vpc_id
  subnet_ids                 = module.networking.private_subnet_ids # 프라이빗 서브넷에 DB 배치
  eks_node_security_group_id = module.security.app_security_group_id  # security 모듈에서 보안 그룹 ID 사용

  # Secrets Manager ARN 참조
  mysql_secret_arn = module.secrets.mysql_secret_arn

  # 선택적 파라미터
  mysql_version           = var.mysql_version
  db_instance_class       = var.db_instance_class
  allocated_storage       = var.allocated_storage
  storage_type            = var.storage_type
  multi_az                = false # A존에만 배포
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  availability_zone_a     = var.availability_zone_a
}

#---------------------------------------
# IRSA 모듈 호출 (IAM Role for Service Accounts)
# 쿠버네티스 서비스 계정이 AWS 리소스에 접근할 수 있도록 설정
#---------------------------------------
module "irsa" {
  source = "./modules/irsa"

  prefix      = var.project_name
  common_tags = local.common_tags
  
  # EKS OIDC 제공자 URL을 직접 문자열로 구성하는 대신 출력값 사용
  # 이렇게 하면 OIDC URL이 변경되더라도 코드를 수정할 필요가 없습니다
  eks_oidc_provider_url = module.compute.oidc_provider_url
  
  service_account_name       = "myapp-sa"
  k8s_namespace              = "default"
  policy_arns                = [module.secrets.secrets_access_policy_arn] # Secrets Manager 접근 정책
  create_k8s_service_account = true
}

#---------------------------------------
# CICD 모듈 호출 - ECR 저장소 및 ArgoCD 설정
#---------------------------------------
module "cicd" {
  source = "./modules/cicd"

  # ECR 설정
  ecr_name            = var.ecr_name
  prefix              = var.project_name
  common_tags         = local.common_tags
  image_tag_mutability = "MUTABLE"
  scan_on_push        = true
  encryption_type     = "AES256"
  
  # ArgoCD 설정
  install_argocd         = true
  argocd_namespace       = "argocd"
  argocd_chart_version   = "5.51.4"
  argocd_admin_password_hash = var.argocd_admin_password_hash
  
  # ECR 이미지 설정
  frontend_image_tag     = "latest"
  ecr_auth_token         = data.aws_ecr_authorization_token.token.password
  
  # 인그레스 설정
  ingress_host           = "argocd.${var.domain_name}"
  frontend_ingress_host  = "frontend.${var.domain_name}"
  
  # Git 저장소 설정 (선택적)
  git_repo_url           = var.frontend_git_repo_url
  git_target_revision    = var.frontend_git_revision
  frontend_namespace     = "frontend"
  
  # 모듈 의존성
  depends_on = [
    module.compute  # EKS 클러스터가 먼저 생성되어야 함
  ]
}

# 별도의 frontend_ecr 모듈은 제거

# ECR 인증 토큰 가져오기
data "aws_ecr_authorization_token" "token" {
  registry_id = data.aws_caller_identity.current.account_id
}

# 현재 AWS 계정 정보 가져오기
data "aws_caller_identity" "current" {}
