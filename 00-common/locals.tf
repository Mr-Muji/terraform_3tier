# 모든 환경에서 공통으로 사용되는 로컬 변수들

locals {
  # 프로젝트 기본 설정
  project_name = "3tier"
  environment  = "dev"
  aws_region   = "ap-northeast-2"

  # 공통 태그
  common_tags = {
    Environment = local.environment
    Project     = local.project_name
    ManagedBy   = "Terraform"
    Owner       = "Jacky"
  }

  # 도메인 설정
  domain_name = "mydairy.my"

  # # 버전 변수 (공통으로 관리)
  # terraform_min_version       = "1.3.0"
  # aws_provider_version        = "5.0.0"
  # kubernetes_provider_version = "2.0.0"
  # helm_provider_version       = "2.0.0"
  # template_provider_version   = "2.2.0"

  # 백엔드 설정은 변수로 사용할 수 없음
  # 그대신 data 가져오는데 쓰는 버킷과 리전 정보를 변수로 사용
  remote_state_bucket = "s3-3tier-terraform-state"
  remote_state_region = "ap-northeast-2"
}
