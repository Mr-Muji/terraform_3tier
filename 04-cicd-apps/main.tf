#---------------------------------------
# CICD 앱 배포 모듈 호출
# ArgoCD, 앱 배포 인프라 구성
#---------------------------------------

# CICD 모듈 호출
module "cicd" {
  source = "../modules/cicd"

  # 프로젝트 기본 정보
  prefix      = local.project_name
  environment = local.environment
  region      = local.aws_region
  common_tags = local.common_tags

  # EKS 클러스터 정보
  eks_cluster_id       = data.terraform_remote_state.compute.outputs.eks_cluster_id
  eks_cluster_endpoint = data.terraform_remote_state.compute.outputs.eks_cluster_endpoint
  eks_cluster_ca_data  = data.terraform_remote_state.compute.outputs.eks_cluster_ca_data

  # ArgoCD 설정
  argocd_namespace = local.argocd_namespace

  # Helm 차트 설정
  helm_charts_repo_url  = local.helm_charts_repo_url
  helm_charts_repo_path = local.helm_charts_repo_path
  helm_charts_revision  = local.helm_charts_revision

  # 도메인 설정 - External DNS 사용을 위해 필요한 것만 남김
  domain_name           = local.domain_name
  # zone_id               = local.zone_id                   # 주석 처리
  # alb_hosted_zone_id    = local.alb_hosted_zone_id        # 주석 처리
  # enable_immediate_dns_setup = local.enable_immediate_dns_setup  # 주석 처리
  frontend_ingress_host = local.domain_name     # local.frontend_ingress_host 대신 domain_name 직접 사용
  frontend_ingress_name = local.frontend_ingress_name
  
  # 저장소 및 로드밸런서 이름 설정
  frontend_repo_name = local.frontend_repo_name
  backend_repo_name = local.backend_repo_name
  frontend_lb_name = local.frontend_lb_name  # 로드밸런서 이름은 여전히 필요

  # ECR 관련 설정
  ecr_force_delete     = local.ecr_force_delete
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true

  # ECR 저장소 URL (이제 00-prerequisites에서 생성됨)
  frontend_repository_url = data.terraform_remote_state.prerequisites.outputs.frontend_ecr_url
  backend_repository_url  = data.terraform_remote_state.prerequisites.outputs.backend_ecr_url

  # 데이터베이스 연결 정보 전달
  db_host     = local.db_host
  db_port     = local.db_port
  db_name     = local.db_name
  db_credentials_secret_arn = local.db_credentials_secret_arn

  # 의존성 주입
  depends_on = [
    data.terraform_remote_state.compute
  ]
}


