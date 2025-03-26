#---------------------------------------
# 프로바이더 및 Terraform 버전 요구사항
#---------------------------------------
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

# 공통 공급자 설정
provider "aws" {
  region = local.aws_region
}

# 이전 상태 파일에서 정보 가져오기
data "terraform_remote_state" "base_infra" {
  backend = "s3"  # remote_state_backend 대신 직접 "s3" 사용

  config = {
    bucket = local.remote_state_bucket
    key    = local.remote_state_key_base  # remote_state_key 대신 remote_state_key_base 사용
    region = local.remote_state_region
  }
}
