#---------------------------------------
# Terraform 설정
#---------------------------------------
terraform {
  # 필요한 공급자(provider) 정의
  required_providers {
    aws = {
      source  = "hashicorp/aws" # AWS 공급자의 소스 위치
      version = "~> 5.0"        # AWS 공급자 버전 (5.x 버전 사용)
    }
  }
  # Terraform 최소 버전 요구사항
  required_version = ">= 1.10.0" # Terraform 1.0.0 이상 필요
}

#---------------------------------------
# AWS 공급자 설정
#---------------------------------------
provider "aws" {
  region = var.aws_region # variables.tf에 정의된 AWS 리전 사용

  # 모든 리소스에 기본적으로 적용될 태그 설정
  default_tags {
    tags = {
      ManagedBy = "Terraform" # 이 리소스가 Terraform으로 관리됨을 표시
      Project   = "tier3"     # 프로젝트 이름 (모든 리소스 공통)
      # 환경별 태그는 tfvars 파일이나 환경 변수로 추가 가능
    }
  }

  # 추가 공급자 옵션:
  # profile = "default"     # AWS 프로필 지정 (필요 시 주석 해제)
  # assume_role { ... }     # 다른 계정의 역할 수임 (필요 시 구성)
}
