#---------------------------------------
# 프로바이더 설정
# AWS 프로바이더 구성
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

# AWS 프로바이더 설정
provider "aws" {
  region = local.aws_region
}