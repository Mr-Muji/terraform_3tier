#---------------------------------------
# 로컬 변수 정의 - 모든 변수 값을 여기서 지정
#---------------------------------------
locals {
  # 프로젝트 기본 설정
  project_name = "tier3"
  environment  = "dev"
  aws_region   = "ap-northeast-2"
  
  # 공통 태그
  common_tags = {
    Owner     = "DevOps"
    ManagedBy = "Terraform"
    Project   = local.project_name
    Environment = local.environment
  }

  # VPC 및 네트워크 설정
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]

  # 서브넷 CIDR 블록 설정
  public_subnet_cidrs = {
    "Azone" = "10.0.1.0/24"
    "Czone" = "10.0.2.0/24"
  }

  private_subnet_cidrs = {
    "Azone" = "10.0.10.0/24"
    "Czone" = "10.0.20.0/24"
  }

  database_subnet_cidrs = {
    "Azone" = "10.0.100.0/24"
    "Czone" = "10.0.200.0/24"
  }

  enable_dns_support   = true
  enable_dns_hostnames = true

  # EKS 클러스터 설정
  eks_cluster_name = "tier3-eks-cluster"

  # 데이터베이스 시크릿 설정
  # 민감한 정보는 환경 변수나 tfvars에서 가져와야 함
  db_username = "admin"  # 실제 환경에서는 이렇게 하드코딩하지 말고 환경 변수 등에서 가져와야 함
  db_password = "Change-me!"  # 실제 환경에서는 이렇게 하드코딩하지 말고 환경 변수 등에서 가져와야 함
  db_name     = "mydairy"
  
  # 도메인 설정
  domain_name = "mydairy.my"  # 도메인이 없으면 빈 문자열로 설정
  
  # NAT 게이트웨이 설정
  single_nat_gateway = true  # 단일 NAT 게이트웨이 사용 여부
}