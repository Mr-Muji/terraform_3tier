terraform {
  # 원격 상태(Remote State) 저장을 위한 S3 백엔드 구성
  backend "s3" {
    bucket       = "terraform-state-tier3-123456" # 상태 파일을 저장할 S3 버킷 이름
    key          = "tier3/02-database/terraform.tfstate"      # 상태 파일의 경로 및 이름
    region       = "ap-northeast-2"               # S3 버킷이 위치한 AWS 리전
    encrypt      = true                           # 상태 파일 암호화 활성화
    use_lockfile = true                           # 상태 잠금에 로컬 파일 사용 (DynamoDB 대신)
  }
}