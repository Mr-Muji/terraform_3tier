terraform {
  backend "s3" {
    bucket       = "terraform-state-tier3-123456"  # S3 버킷 이름
    key          = "tier3/11-access-vpc/terraform.tfstate"  # 상태 파일의 경로
    region       = "ap-northeast-2"  # AWS 리전
    encrypt      = true  # 상태 파일 암호화 여부
    use_lockfile = true  # 상태 파일 잠금 사용 여부
  }
}