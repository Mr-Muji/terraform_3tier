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
  
  # 도메인 설정 - 03-compute와 동일하게 맞추기
  domain_name = "mydairy.my"
  zone_id = "Z01078892J4R7FP4HB44O" # aws route53 list-hosted-zones 명령어로 확인 혹은 콘솔에서 호스팅영역 ID 항목에서 확인
  
  # ArgoCD 설정 - 03-compute에서 이미 설치됨을 반영
  install_argocd = false  # 03번에서 이미 설치했으므로 false로 설정
  argocd_namespace = data.terraform_remote_state.compute.outputs.argocd_namespace
  
  # 인그레스 설정
  ingress_enabled = true
  ingress_host = "argocd.${local.domain_name}"
  ingress_class = "alb"
  ingress_annotations = {
    "alb.ingress.kubernetes.io/scheme" = "internet-facing"
    "alb.ingress.kubernetes.io/target-type" = "ip"
  }
  
  # Git 저장소 설정
  frontend_git_repo_url = "https://github.com/yourusername/frontend-app.git"
  frontend_git_revision = "main"
  frontend_manifest_path = "kubernetes"
  frontend_namespace = "frontend"
  
  # 앱 배포 설정
  helm_charts_repo_url = "https://github.com/yourusername/helm-charts.git"
  helm_charts_repo_path = "charts"
  helm_charts_revision = "main"
  
  # ECR 관련 설정
  ecr_force_delete = false
  frontend_image_tag = "latest"
  
  # 기타 설정
  k8s_cleanup_wait_seconds = 300
  frontend_ingress_host = "www.${local.domain_name}"    # 서브도메인 사용
  frontend_ingress_name = "frontend"  # 인그레스 이름 추가
  
  # 원격 상태 설정
  remote_state_bucket = "terraform-state-tier3-123456"
  remote_state_key    = "tier3/03-compute/terraform.tfstate"
  remote_state_region = local.aws_region
}
