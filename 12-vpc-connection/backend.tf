terraform {
  backend "s3" {
    bucket         = "terraform-state-tier3-123456"
    key            = "tier3/12-vpc-connection/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    use_lockfile = true  # 상태 파일 잠금 사용 여부
  }
} 