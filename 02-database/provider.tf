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

# 01단계 상태 파일에서 출력값 가져오기
data "terraform_remote_state" "base_infra" {
  backend = local.remote_state_backend

  config = {
    bucket = local.remote_state_bucket
    key    = local.remote_state_key
    region = local.remote_state_region
  }
}
