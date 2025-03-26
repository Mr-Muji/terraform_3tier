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

  # HPA 지원을 위한 Metrics Server 설정
  enable_metrics_server = true # HPA 사용을 위해 활성화

  # 로드 밸런서 컨트롤러 설정
  enable_aws_load_balancer_controller = true

  # 태그 설정
  tags = local.common_tags

  # External DNS 설정
  domain_name = local.domain_name
}

# EKS 클러스터가 완전히 준비될 때까지 대기
resource "time_sleep" "wait_for_eks" {
  depends_on      = [module.compute]
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
  eks_cluster_id = module.compute.cluster_id
  region         = local.aws_region

  # ArgoCD 설정
  argocd_namespace           = "argocd"
  argocd_chart_version       = local.argocd_chart_version
  argocd_admin_password_hash = local.argocd_admin_password_hash

  # 인그레스 설정
  ingress_enabled     = local.argocd_ingress_enabled
  ingress_host        = local.argocd_ingress_host
  ingress_class       = local.argocd_ingress_class
  ingress_annotations = local.ingress_annotations

  # Route53 설정 추가
  create_route53_record = false # ArgoCD 도메인 레코드 생성 비활성화

  # EKS 클러스터 준비 후 설치 보장
  depends_on = [
    module.compute,
    time_sleep.wait_for_cluster
  ]

  use_external_dns = true # External DNS가 DNS 레코드를 관리하도록 함
}

# 클러스터 완전 준비를 위한 대기 시간
resource "time_sleep" "wait_for_cluster" {
  depends_on      = [module.compute]
  create_duration = "30s"
}

#---------------------------------------
# Jenkins 설치 (CI 파이프라인 구성용)
#---------------------------------------
module "jenkins" {
  source = "../modules/jenkins"

  # 프로젝트 기본 정보
  name_prefix = local.project_name
  environment = local.environment

  # ECR 설정 추가
  backend_ecr_url  = local.backend_ecr_url  # ECR URL 추가
  backend_ecr_name = local.backend_ecr_name # ECR 이름 추가

  # 레포지토리 설정 추가
  backend_repo_url    = local.backend_repo_url
  backend_repo_org    = local.backend_repo_org
  backend_repo_branch = local.backend_repo_branch
  jenkins_job_suffix  = local.jenkins_job_suffix
  job_description     = local.job_description
  scm_poll_interval   = local.scm_poll_interval

  # OIDC 제공자 ARN (필수 변수)
  oidc_provider_arn = module.compute.oidc_provider_arn

  # Jenkins 네임스페이스 설정 (var.namespace에 맞춤)
  namespace = local.jenkins_namespace

  # Jenkins 볼륨 설정
  jenkins_pvc_size   = local.jenkins_pvc_size
  storage_class_name = local.storage_class_name

  # AWS Secrets Manager에서 가져온 ARN 전달
  jenkins_secret_arn = data.terraform_remote_state.base_infra.outputs.jenkins_secret_arn

  # 기존에 하드코딩된 비밀번호는 Secrets Manager에 값이 없을 경우 폴백으로 사용
  jenkins_admin_password = local.jenkins_admin_password

  # Jenkins 서비스 설정
  jenkins_service_type = local.jenkins_service_type

  # Jenkins Helm 차트 설정
  jenkins_chart_version = local.jenkins_chart_version

  # 인그레스 설정
  ingress_enabled = local.jenkins_ingress_enabled
  ingress_host    = local.jenkins_ingress_host
  ingress_class   = local.jenkins_ingress_class

  # 태그 설정 (필요한 경우)
  tags = local.common_tags

  # 의존성 설정
  depends_on = [module.compute, time_sleep.wait_for_eks]

  # 기존 github_token 대신 github_token_secret_arn 사용
  github_token_secret_arn = data.terraform_remote_state.base_infra.outputs.github_token_secret_arn
}


