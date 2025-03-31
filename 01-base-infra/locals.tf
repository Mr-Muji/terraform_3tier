#---------------------------------------
# 로컬 변수 정의
#---------------------------------------
locals {
  # common 모듈에서 기본 설정 가져오기
  project_name = data.terraform_remote_state.common.outputs.project_name
  environment  = data.terraform_remote_state.common.outputs.environment
  aws_region   = data.terraform_remote_state.common.outputs.aws_region
  
  # 공통 태그 - common 태그에 모듈별 태그 추가
  common_tags = merge(
    data.terraform_remote_state.common.outputs.common_tags,
    {
      Stage = "Base-Infra"
    }
  )
  
  # VPC 및 네트워크 설정 - 모듈 고유 값 (common으로 이동하지 않은 값)
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
  eks_cluster_name = "eks-cluster-3tier"

  # 도메인 설정 - common에서 가져오기
  domain_name = data.terraform_remote_state.common.outputs.domain_name
  
  # NAT 게이트웨이 설정
  single_nat_gateway = true  # 단일 NAT 게이트웨이 사용 여부
}