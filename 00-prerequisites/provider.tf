#---------------------------------------
# 00단계: 프로바이더 및 Terraform 버전 요구사항
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

# 기본 AWS 프로바이더 설정
provider "aws" {
  region = local.aws_region
}

# 미국 동부(버지니아) 리전에 위치한 ACM 인증서를 참조할 프로바이더 설정
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}