#=======================================================
# prerequisites: 기반 인프라 구성 요소 생성
#=======================================================
# 이 파일에서 생성하는 리소스:
# 1. 프론트엔드 인프라 (frontend 모듈)
#    - S3 버킷 및 관련 설정
#    - CloudFront 배포
#    - Route53 DNS 레코드
# 2. ECR 저장소
#    - 프론트엔드 이미지 저장소 (비활성화)
#    - 백엔드 이미지 저장소
#=======================================================

#---------------------------------------
# 2. 프론트엔드 인프라 모듈 호출
#---------------------------------------
module "frontend" {
  source = "../modules/frontend"
  count  = local.create_frontend_s3 ? 1 : 0  # 조건부 생성
  
  # 프로젝트 기본 정보
  project_name = local.project_name
  environment  = local.environment
  
  # 도메인 설정
  domain_name = local.domain_name
  zone_id     = local.zone_id
  
  # CloudFront 설정
  cloudfront_price_class = local.cloudfront_price_class
  acm_certificate_arn    = local.acm_certificate_arn
  
  # 리소스 제어 설정
  create_route53_records = local.create_route53_records
  force_destroy          = true  # 개발 환경에서는 true, 프로덕션에서는 false 권장
  
  # 공통 태그
  common_tags = local.common_tags
  
  # 추가 변수들
  bucket_name_prefix = local.frontend_bucket_name_prefix
  cors_origins       = local.frontend_cors_origins
  cache_policy_id    = local.frontend_cache_policy_id
}

#---------------------------------------
# 3. ECR 저장소 생성 - 컨테이너 이미지 저장소
#---------------------------------------

# 3-1. 프론트엔드 ECR 저장소 생성
module "frontend_ecr" {
  count  = local.create_frontend_ecr ? 1 : 0  # 조건부 생성
  source = "../modules/ecr"  # ECR 모듈 사용
  
  repository_name = "${local.project_name}-frontend"  # 저장소 이름
  component_name  = "frontend"  # 컴포넌트 이름
  
  # 이미지 설정
  image_tag_mutability = local.ecr_image_tag_mutability  # 태그 변경 가능 여부
  scan_on_push         = local.ecr_scan_on_push  # 푸시 시 이미지 스캔
  force_delete         = local.ecr_force_delete  # 강제 삭제 허용
  
  # 라이프사이클 설정
  enable_lifecycle_policy = local.ecr_lifecycle_policy_enabled  # 라이프사이클 정책 활성화
  keep_image_count        = local.ecr_keep_image_count  # 보관할 이미지 수
  
  # 태그 설정
  common_tags = local.common_tags  # 공통 태그
  additional_tags = {
    ApplicationType = "frontend"  # 애플리케이션 타입
    Service         = "web"  # 서비스 유형
    CreatedBy       = "terraform-pre"  # 생성자
  }
}

# 3-2. 백엔드 ECR 저장소 생성
module "backend_ecr" {
  count  = local.create_backend_ecr ? 1 : 0  # 조건부 생성
  source = "../modules/ecr"  # ECR 모듈 사용
  
  repository_name = "${local.project_name}-backend"  # 저장소 이름
  component_name  = "backend"  # 컴포넌트 이름
  
  # 이미지 설정
  image_tag_mutability = local.ecr_image_tag_mutability  # 태그 변경 가능 여부
  scan_on_push         = local.ecr_scan_on_push  # 푸시 시 이미지 스캔
  force_delete         = local.ecr_force_delete  # 강제 삭제 허용
  
  # 라이프사이클 설정
  enable_lifecycle_policy = local.ecr_lifecycle_policy_enabled  # 라이프사이클 정책 활성화
  keep_image_count        = local.ecr_keep_image_count  # 보관할 이미지 수
  
  # 태그 설정
  common_tags = local.common_tags  # 공통 태그
  additional_tags = {
    ApplicationType = "backend"  # 애플리케이션 타입
    Service         = "api"  # 서비스 유형
    CreatedBy       = "terraform-pre"  # 생성자
  }
}
