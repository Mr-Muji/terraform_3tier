#---------------------------------------
# 03-compute: EKS 클러스터 생성
# 이전 단계에서 생성된 VPC, 서브넷 정보를 활용하여 컴퓨트 리소스 생성
#---------------------------------------


#---------------------------------------
# EKS 클러스터 모듈 호출
#---------------------------------------
module "compute" {
  source = "../modules/compute"

  # 기본 설정
  project_name     = local.project_name
  environment      = local.environment
  eks_cluster_name = local.eks_cluster_name

  # 네트워크 설정 (이전 단계에서 생성된 리소스 참조)
  vpc_id     = data.terraform_remote_state.base_infra.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.base_infra.outputs.private_subnet_ids

  # 클러스터 설정
  kubernetes_version = local.kubernetes_version

  # 엔드포인트 접근 설정
  endpoint_private_access = local.endpoint_private_access
  endpoint_public_access  = local.endpoint_public_access
  public_access_cidrs     = local.public_access_cidrs

  # 노드 그룹 설정
  node_group_name    = local.node_group_name
  node_instance_type = local.node_instance_type
  node_disk_size     = local.node_disk_size
  node_desired_size  = local.node_desired_size
  node_min_size      = local.node_min_size
  node_max_size      = local.node_max_size

  # 관찰성 설정
  enable_cloudwatch_observability = local.enable_cloudwatch_observability

  # 로드 밸런서 컨트롤러 설정
  enable_aws_load_balancer_controller = true

  # 태그 설정
  tags = local.common_tags
}

# EKS 클러스터가 완전히 준비될 때까지 대기
resource "time_sleep" "wait_for_eks" {
  depends_on = [module.compute]
  create_duration = "30s"
}

#---------------------------------------
# IRSA 모듈 호출 (IAM Role for Service Accounts)
# 쿠버네티스 서비스 계정이 AWS 리소스에 접근할 수 있도록 설정
#---------------------------------------
module "irsa" {
  source = "../modules/irsa"

  prefix      = local.project_name
  common_tags = local.common_tags

  eks_oidc_provider_url = module.compute.oidc_provider_url

  service_account_name       = local.service_account_name
  k8s_namespace              = local.k8s_namespace
  policy_arns                = [data.terraform_remote_state.base_infra.outputs.secrets_access_policy_arn]
  create_k8s_service_account = true

  # 컴퓨팅 모듈에 의존성 추가
  depends_on = [
    module.compute,
    time_sleep.wait_for_eks
  ]
}

# ArgoCD 모듈 추가 - 컴퓨트 모듈 실행 이후에 실행됨
module "argocd" {
  source = "../modules/argocd"
  
  # 클러스터 정보 전달
  eks_cluster_id       = module.compute.cluster_id
  eks_cluster_endpoint = module.compute.cluster_endpoint
  eks_cluster_ca_data  = module.compute.cluster_certificate_authority_data
  cluster_exists       = true
  
  # 리전 설정
  region = local.aws_region
  
  # ArgoCD 설정
  argocd_namespace        = "argocd"
  argocd_chart_version    = local.argocd_chart_version
  argocd_admin_password_hash = local.argocd_admin_password_hash
  
  # 인그레스 설정
  ingress_enabled    = local.ingress_enabled 
  ingress_host       = local.argocd_ingress_host
  ingress_class      = local.ingress_class
  ingress_annotations = local.ingress_annotations
  
  # 도메인 설정
  domain_name = local.domain_name
  zone_id     = local.zone_id
  
  # EKS 클러스터 준비 후 설치 보장
  depends_on = [
    module.compute,
    time_sleep.wait_for_cluster
  ]
}

# 클러스터 완전 준비를 위한 대기 시간
resource "time_sleep" "wait_for_cluster" {
  depends_on = [module.compute]
  create_duration = "10s"
}