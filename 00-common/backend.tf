# 모든 모듈에서 공통으로 사용될 백엔드 설정
terraform {
  backend "s3" {
    bucket       = "s3-3tier-terraform-state"
    key          = "3tier/common/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true
  }
}
