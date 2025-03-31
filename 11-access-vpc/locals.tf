# 다른 테라폼 폴더의 provider.tf 에 아래 코드 추가
data "terraform_remote_state" "common" {
  backend = "s3"
  
  config = {
    bucket  = "s3-3tier-terraform-state"
    key     = "common/terraform.tfstate"
    region  = "ap-northeast-2"
  }
}

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
    Stage       = "Access-VPC"
  }

  # VPC 설정
  vpc_name = "access"
  vpc_cidr = "10.10.0.0/16" # Access VPC CIDR

  # 가용영역 설정
  azs = ["ap-northeast-2a", "ap-northeast-2c"]

  # 서브넷 CIDR 설정
  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]
}
