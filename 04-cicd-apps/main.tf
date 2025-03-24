#---------------------------------------
# CICD 앱 배포 모듈 호출
# ArgoCD, 앱 배포 인프라 구성
#---------------------------------------

# CICD 모듈 호출
module "cicd" {
  source = "../modules/cicd"
  
  # 프로젝트 기본 정보
  prefix      = local.project_name
  ecr_name    = "${local.project_name}-ecr"
  environment = local.environment
  region      = local.aws_region
  common_tags = local.common_tags
  
  # EKS 클러스터 정보 - 원격 상태에서 가져오기
  eks_cluster_id       = data.terraform_remote_state.compute.outputs.eks_cluster_id
  eks_cluster_endpoint = data.terraform_remote_state.compute.outputs.eks_cluster_endpoint
  eks_cluster_ca_data  = data.terraform_remote_state.compute.outputs.eks_cluster_ca_data
  cluster_exists       = true  # 클러스터가 이미 존재함을 명시
  
  # ArgoCD 설정 - 이미 설치된 ArgoCD 참조
  argocd_namespace = local.argocd_namespace
  
  # 앱 배포 설정
  git_repo_url         = local.frontend_git_repo_url
  git_target_revision  = local.frontend_git_revision
  frontend_manifest_path = local.frontend_manifest_path
  frontend_namespace   = local.frontend_namespace
  
  # Helm 차트 설정
  helm_charts_repo_url  = local.helm_charts_repo_url
  helm_charts_repo_path = local.helm_charts_repo_path
  helm_charts_revision  = local.helm_charts_revision
  
  # 도메인 설정
  domain_name          = local.domain_name
  zone_id              = local.zone_id
  frontend_ingress_host = local.frontend_ingress_host
  frontend_ingress_name = local.frontend_ingress_name
  
  # ECR 관련 설정
  ecr_force_delete    = local.ecr_force_delete
  frontend_image_tag  = local.frontend_image_tag
  
  # 기타 설정
  ecr_auth_token           = data.aws_ecr_authorization_token.token.password
  
  # 의존성 주입
  depends_on = [
    data.terraform_remote_state.compute
  ]
}


