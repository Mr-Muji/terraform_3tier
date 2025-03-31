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
  helm_charts_repo_url = "https://github.com/Mr-Muji/3tier-practice.git"
  helm_charts_repo_path = "argocd/apps"
  helm_charts_revision = "main"
  
  # ECR 관련 설정
  ecr_force_delete = false
  
  # 프론트엔드 배포 비활성화 - S3에서 직접 서빙하므로 필요 없음
  enable_frontend_deployment = false
  
  # 원격 상태 설정
  remote_state_bucket = "terraform-state-tier3-123456"
  remote_state_key    = "tier3/03-compute/terraform.tfstate"
  remote_state_region = local.aws_region
  
  # ECR 저장소 이름 설정 - 백엔드만 유지
  backend_repo_name = "${local.project_name}-backend"
  
  # 데이터베이스 연결 정보 - 02-database에서 가져옴
  db_host = data.terraform_remote_state.database.outputs.db_instance_endpoint
  db_port = "3306"
  db_name = data.terraform_remote_state.database.outputs.db_instance_name
  
  # Secrets Manager ARN - 01번 모듈(base-infra)에서 가져옴
  db_credentials_secret_arn = data.terraform_remote_state.base_infra.outputs.mysql_secret_arn
}
