#---------------------------------------
# 공급자 설정
#---------------------------------------
provider "aws" {
  region = local.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

#---------------------------------------
# 데이터 소스 - 메인 VPC 정보 가져오기
#---------------------------------------
data "terraform_remote_state" "main_vpc" {
  backend = "s3"
  
  config = {
    bucket  = "terraform-state-tier3-123456"
    key     = "tier3/01-base-infra/terraform.tfstate"
    region  = "ap-northeast-2"
  }
}

#---------------------------------------
# 데이터 소스 - 컴퓨트(EKS) 정보 가져오기
#---------------------------------------
data "terraform_remote_state" "compute" {
  backend = "s3"
  
  config = {
    bucket  = "terraform-state-tier3-123456"
    key     = "tier3/03-compute/terraform.tfstate"
    region  = "ap-northeast-2"
  }
}

# access_vpc 데이터 소스는 제거 (직접 생성하므로) 

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
  }
} 