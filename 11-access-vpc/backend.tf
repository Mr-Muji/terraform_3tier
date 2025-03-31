terraform {
  backend "s3" {
    bucket       = "s3-3tier-terraform-state"  # 수정
    key          = "3tier/access-vpc/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true
  }
}