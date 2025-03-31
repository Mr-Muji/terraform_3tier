#---------------------------------------
# AWS 공급자 설정
#---------------------------------------
# common 모듈의 원격 상태 참조
data "terraform_remote_state" "common" {
  backend = "s3"
  
  config = {
    bucket  = "s3-3tier-terraform-state"
    key     = "3tier/common/terraform.tfstate"
    region  = "ap-northeast-2"
  }
}

provider "aws" {
  # common 모듈에서 리전 정보 가져오기
  region = data.terraform_remote_state.common.outputs.aws_region
  
  # 기본 태그 설정 - common 태그에 모듈별 태그 추가
  default_tags {
    tags = merge(
      data.terraform_remote_state.common.outputs.common_tags,
      {
        Stage = "Base-Infra"
      }
    )
  }
}

# 테라폼 버전 및 프로바이더 버전 요구사항 - 하드코딩
terraform {
  required_version = ">= 1.3.0"  # common.terraform_min_version과 일치시켜야 함
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"  # common.aws_provider_version과 일치시켜야 함
    }
  }
}
