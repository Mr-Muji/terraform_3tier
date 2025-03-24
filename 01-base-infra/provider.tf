#---------------------------------------
# AWS 공급자 설정
#---------------------------------------
provider "aws" {
  region = local.aws_region

  # 모든 리소스에 기본적으로 적용될 태그 설정
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = local.project_name
      Environment = local.environment
    }
  }
}

# 버전 제약 조건 설정
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  required_version = ">= 1.0.0"
}
