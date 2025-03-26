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
  
  # ECR 저장소 생성 설정
  create_frontend_ecr = true  # 프론트엔드 ECR 저장소 생성 여부
  create_backend_ecr = true   # 백엔드 ECR 저장소 생성 여부
  
  # ECR 저장소 설정
  ecr_image_tag_mutability = "MUTABLE"
  ecr_scan_on_push = true
  ecr_force_delete = false    # 프로덕션에서는 false 권장
  ecr_lifecycle_policy_enabled = true
  ecr_keep_image_count = 10   # 보관할 최근 이미지 수
}