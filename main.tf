#---------------------------------------
# 네트워킹 모듈 호출
# VPC, 서브넷, 라우팅 테이블 등 기본 네트워크 인프라 생성
#---------------------------------------
module "networking" {
  source = "./modules/networking"

  # 기본 변수 전달
  project_name        = var.project_name        # 프로젝트 이름 (예: "tier3")
  environment         = var.environment         # 배포 환경 (예: "dev", "staging", "prod")
  vpc_cidr            = var.vpc_cidr            # VPC CIDR 블록 (예: "10.0.0.0/16")
  availability_zones  = var.availability_zones  # 사용할 가용 영역 목록 (예: ["ap-northeast-2a", "ap-northeast-2c"])
  public_subnet_cidrs = var.public_subnet_cidrs # 퍼블릭 서브넷 CIDR 블록 맵 (예: {"Azone"="10.0.1.0/24", "Czone"="10.0.2.0/24"})
  nat_subnet_cidrs    = var.nat_subnet_cidrs    # NAT 서브넷 CIDR 블록 맵 (예: {"Azone"="10.0.10.0/24", "Czone"="10.0.20.0/24"})
  private_subnet_cidrs = var.private_subnet_cidrs # 프라이빗 서브넷 CIDR 블록 맵 (예: {"Azone"="10.0.100.0/24", "Czone"="10.0.200.0/24"})
  enable_dns_support   = var.enable_dns_support   # VPC에서 DNS 지원 활성화 여부 (기본값: true)
  enable_dns_hostnames = var.enable_dns_hostnames # VPC에서 DNS 호스트 이름 활성화 여부 (기본값: true)
}

#---------------------------------------
# 보안 모듈 호출
# 보안 그룹, IAM 역할 등 보안 관련 리소스 생성
#---------------------------------------
module "security" {
  source = "./modules/security"

  # 네트워킹 모듈에서 출력된 값 전달
  vpc_id             = module.networking.vpc_id           # VPC ID
  vpc_cidr           = var.vpc_cidr                       # VPC CIDR 블록
  
  # 기본 변수 전달
  project_name       = var.project_name                   # 프로젝트 이름
  environment        = var.environment                    # 환경 (dev, staging, prod)
  
  # 서브넷 ID 전달 - 리소스 배치에 사용됨
  public_subnet_ids  = module.networking.public_subnet_ids  # 퍼블릭 서브넷 ID 목록
  nat_subnet_ids     = module.networking.nat_subnet_ids     # NAT 서브넷 ID 목록
  private_subnet_ids = module.networking.private_subnet_ids # 프라이빗 서브넷 ID 목록
  
  # EKS 관련 설정
  eks_cluster_name   = var.eks_cluster_name                # EKS 클러스터 이름
}

#---------------------------------------
# Compute 모듈 호출 (EKS 클러스터)
# 애플리케이션 계층을 위한 쿠버네티스 클러스터 생성
#---------------------------------------
module "compute" {
  source = "./modules/compute"

  project_name    = var.project_name
  environment     = var.environment
  eks_cluster_name = var.eks_cluster_name
  
  # 네트워킹 모듈에서 출력된 값 사용
  vpc_id          = module.networking.vpc_id
  subnet_ids      = module.networking.nat_subnet_ids
  
  # 보안 모듈에서 출력된 값 사용
  additional_security_group_ids = [module.security.app_security_group_id]
  
  # 노드 그룹 설정
  node_instance_types = ["t2.micro"]
  node_disk_size      = 10
  node_capacity_type  = "ON_DEMAND"
  node_desired_size   = 2
  node_min_size       = 1
  node_max_size       = 5
  
  # 엔드포인트 접근 설정
  endpoint_private_access = true
  endpoint_public_access  = false
  public_access_cidrs     = var.public_access_cidrs
  
  # 클러스터 버전 및 설정
  kubernetes_version = var.kubernetes_version
  enabled_cluster_log_types = var.enabled_cluster_log_types
  # public_access_cidrs = var.public_access_cidrs
  
  # 추가 태그
  tags = var.common_tags
}