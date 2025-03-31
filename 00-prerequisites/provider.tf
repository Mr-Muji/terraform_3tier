#---------------------------------------
# 프로바이더 및 Terraform 버전 요구사항
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
        Stage = "Prerequisites"
      }
    )
  }
}

# 테라폼 버전 및 프로바이더 버전 요구사항
terraform {
  # common에서 정의된 최소 버전 사용
  required_version = ">= 1.3.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

# 미국 동부(버지니아) 리전에 위치한 ACM 인증서를 참조할 프로바이더 설정
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}