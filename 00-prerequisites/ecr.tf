#---------------------------------------
# ECR 저장소 생성
# 프론트엔드 및 백엔드 애플리케이션용 컨테이너 이미지 저장소
#---------------------------------------

# 프론트엔드 ECR 저장소 생성
module "frontend_ecr" {
  # 생성 여부 제어
  count  = local.create_frontend_ecr ? 1 : 0
  source = "../modules/ecr"
  
  repository_name = "${local.project_name}-frontend"
  component_name  = "frontend"
  
  # 이미지 설정
  image_tag_mutability = local.ecr_image_tag_mutability
  scan_on_push         = local.ecr_scan_on_push
  force_delete         = local.ecr_force_delete
  
  # 라이프사이클 설정
  enable_lifecycle_policy = local.ecr_lifecycle_policy_enabled
  keep_image_count        = local.ecr_keep_image_count
  
  # 태그 설정
  common_tags = local.common_tags
  additional_tags = {
    ApplicationType = "frontend"
    Service         = "web"
    CreatedBy       = "terraform-00-pre"
  }
}

# 백엔드 ECR 저장소 생성
module "backend_ecr" {
  # 생성 여부 제어
  count  = local.create_backend_ecr ? 1 : 0
  source = "../modules/ecr"
  
  repository_name = "${local.project_name}-backend"
  component_name  = "backend"
  
  # 이미지 설정
  image_tag_mutability = local.ecr_image_tag_mutability
  scan_on_push         = local.ecr_scan_on_push
  force_delete         = local.ecr_force_delete
  
  # 라이프사이클 설정
  enable_lifecycle_policy = local.ecr_lifecycle_policy_enabled
  keep_image_count        = local.ecr_keep_image_count
  
  # 태그 설정
  common_tags = local.common_tags
  additional_tags = {
    ApplicationType = "backend"
    Service         = "api"
    CreatedBy       = "terraform-00-pre"
  }
}
