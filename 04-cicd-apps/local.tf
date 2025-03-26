#---------------------------------------
# 로컬 변수 정의 - 모든 변수 값을 여기서 지정
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
    Stage       = "04-CICD-Apps"
  }
  
  # 도메인 설정
  domain_name = "mydairy.my"
  # zone_id = "Z01078892J4R7FP4HB44O"  # External DNS 사용을 위해 주석 처리
  
  # ALB 호스팅 영역 ID - External DNS 사용을 위해 주석 처리
  # alb_hosted_zone_id = "ZWKZPGTI48KDX"
  
  # 도메인 즉시 설정 활성화 - External DNS 사용을 위해 주석 처리
  # enable_immediate_dns_setup = true
  
  # ArgoCD 설정 - 03-compute에서 이미 설치됨
  argocd_namespace = data.terraform_remote_state.compute.outputs.argocd_namespace
  
  # App of Apps 배포 설정
  helm_charts_repo_url = "https://github.com/Mr-Muji/3tier-manifest.git"
  helm_charts_repo_path = "apps"
  helm_charts_revision = "main"
  
  # ECR 관련 설정
  ecr_force_delete = false
  
  # 프론트엔드 설정 - External DNS가 관리할 예정이므로 주석 처리
  # frontend_ingress_host = "${local.domain_name}"
  frontend_ingress_name = "frontend"
  
  # 원격 상태 설정
  remote_state_bucket = "terraform-state-tier3-123456"
  remote_state_key    = "tier3/03-compute/terraform.tfstate"
  remote_state_region = local.aws_region
  
  # ECR 저장소 이름 설정
  frontend_repo_name = "${local.project_name}-frontend"
  backend_repo_name = "${local.project_name}-backend"
  
  # 로드밸런서 이름 설정 - 여전히 필요합니다 (인그레스 어노테이션에 사용)
  frontend_lb_name = "${local.project_name}-frontend-lb"
}
