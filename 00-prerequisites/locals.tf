#=======================================================
# 00단계: 로컬 변수 정의 - 사전 준비 리소스
#=======================================================
# 이 파일은 다음 내용을 정의합니다:
# 1. 프로젝트 기본 정보 (이름, 환경, 리전 등)
# 2. 공통 태그
# 3. ECR 저장소 설정
# 4. 도메인 및 Route53 설정
# 5. 리소스 생성 제어 플래그
# 6. CloudFront 및 S3 설정
#=======================================================

locals {
  #---------------------------------------
  # 1. 프로젝트 기본 정보 - common 모듈에서 가져오기
  #---------------------------------------
  project_name = data.terraform_remote_state.common.outputs.project_name  # 프로젝트 이름
  environment  = data.terraform_remote_state.common.outputs.environment   # 환경 (dev, stage, prod 등)
  aws_region   = data.terraform_remote_state.common.outputs.aws_region    # AWS 리전
  
  #---------------------------------------
  # 2. 공통 태그 설정 - 리소스 관리 및 비용 추적
  #---------------------------------------
  common_tags = merge(
    data.terraform_remote_state.common.outputs.common_tags,  # 공통 모듈의 태그
    {
      Stage = "Prerequisites"  # 현재 단계 표시
    }
  )
  
  #---------------------------------------
  # 3. ECR 저장소 관련 설정
  #---------------------------------------
  # ECR 저장소 이름 목록
  ecr_repositories = [
    "${local.project_name}-frontend",  # 프론트엔드 저장소
    "${local.project_name}-backend",   # 백엔드 저장소
    "${local.project_name}-api"        # API 저장소
  ]
  
  # ECR 설정
  image_scanning_configuration = true          # 이미지 스캔 활성화
  image_tag_mutability = "MUTABLE"             # 태그 변경 가능
  
  #---------------------------------------
  # 4. 도메인 및 Route53 설정
  #---------------------------------------
  domain_name = "mydairy.my"                   # 프로젝트 도메인 이름
  zone_id     = "Z01078892J4R7FP4HB44O"        # Route53 호스팅 영역 ID
  
  #---------------------------------------
  # 5. 리소스 생성 제어 플래그 - 환경별 구성 제어
  #---------------------------------------
  # ECR 저장소 생성 플래그
  create_frontend_ecr = false                  # 프론트엔드 ECR 저장소 생성 여부
  create_backend_ecr = true                    # 백엔드 ECR 저장소 생성 여부
  
  # 기존 리소스 관리 설정
  use_existing_distribution = true             # 기존 CloudFront 배포 사용 여부
  
  # 리소스 생성 플래그
  create_frontend_s3 = true                    # 프론트엔드 S3 버킷 생성 여부
  create_cloudfront = true                     # CloudFront 배포 생성 여부
  create_route53_records = true                # Route53 레코드 생성 여부
  
  #---------------------------------------
  # 6. CloudFront, ECR, ACM 설정
  #---------------------------------------
  # CloudFront 설정
  cloudfront_price_class = "PriceClass_100"    # 가격 등급 (PriceClass_100: 미국, 유럽, 캐나다만)
  
  # ACM 인증서 ARN (반드시 us-east-1 리전에 있어야 함)
  acm_certificate_arn = "arn:aws:acm:us-east-1:183631327456:certificate/f7e962fb-4afa-446b-9b04-8c4e330a142b"
  
  # ECR 저장소 상세 설정
  ecr_image_tag_mutability = "MUTABLE"         # 이미지 태그 변경 가능 여부
  ecr_scan_on_push = true                      # 푸시 시 이미지 취약점 스캔
  ecr_force_delete = false                     # 강제 삭제 여부 (프로덕션에서는 false 권장)
  ecr_lifecycle_policy_enabled = true          # 라이프사이클 정책 활성화
  ecr_keep_image_count = 10                    # 보관할 최근 이미지 수
  
  #---------------------------------------
  # 7. 프론트엔드 모듈 추가 설정
  #---------------------------------------
  # 버킷 이름 관련 설정
  frontend_bucket_name_prefix = local.project_name
  
  # CORS 설정
  frontend_cors_origins = ["https://${local.domain_name}", "https://www.${local.domain_name}"]
  
  # CloudFront 캐시 정책 설정
  # 기본값: Managed-CachingOptimized 정책 ID
  frontend_cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
} 