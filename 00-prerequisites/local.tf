#---------------------------------------
# 00단계: 로컬 변수 정의 - 사전 준비 리소스
#---------------------------------------
locals {
  # 프로젝트 기본 설정
  project_name = "tier3"
  environment  = "dev"
  aws_region   = "ap-northeast-2"
  
  # 공통 태그
  common_tags = {
    Owner       = "DevOps"
    ManagedBy   = "Terraform"
    Project     = local.project_name
    Environment = local.environment
    Stage       = "00-Pre"
  }
  
  # 도메인 설정
  domain_name = "mydairy.my"
  zone_id     = "Z01078892J4R7FP4HB44O"  # Route53 호스팅 영역 ID
  
  # ECR 저장소 생성 설정
  create_frontend_ecr = true  # 프론트엔드 ECR 저장소 생성 여부
  create_backend_ecr = true   # 백엔드 ECR 저장소 생성 여부
  
  # 이미 존재하는 리소스 관리를 위한 설정
  use_existing_distribution = true  # 이미 존재하는 CloudFront 배포 사용
  
  # S3 및 CloudFront 설정
  create_frontend_s3 = true       # 프론트엔드 S3 버킷 생성 여부
  create_cloudfront = true        # CloudFront 배포 생성 여부
  create_route53_records = true   # Route53 레코드 생성 여부
  
  # CloudFront 설정
  cloudfront_price_class = "PriceClass_100"  # 가격 등급 (PriceClass_100: 미국, 유럽, 캐나다만)
  
  # ACM 인증서 ARN (us-east-1 리전에 있어야 함)
  acm_certificate_arn = "arn:aws:acm:us-east-1:183631327456:certificate/f7e962fb-4afa-446b-9b04-8c4e330a142b"
  
  # ECR 저장소 설정
  ecr_image_tag_mutability = "MUTABLE"
  ecr_scan_on_push = true
  ecr_force_delete = false    # 프로덕션에서는 false 권장
  ecr_lifecycle_policy_enabled = true
  ecr_keep_image_count = 10   # 보관할 최근 이미지 수
} 