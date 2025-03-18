# AWS 프로바이더 설정
provider "aws" {
  region = var.aws_region

  # 기본 태그 설정 - 모든 리소스에 적용됨
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}