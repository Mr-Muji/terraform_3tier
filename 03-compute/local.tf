#---------------------------------------
# 03단계: 로컬 변수 정의 - 컴퓨트 리소스 설정
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
    Stage       = "03-Compute"
  }

  # 가용 영역 설정
  availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]

  # EKS 클러스터 설정
  eks_cluster_name   = "tier3-eks-cluster"
  kubernetes_version = "1.31" # 최신 버전으로 설정

  # EKS 클러스터 엔드포인트 접근 설정
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = ["0.0.0.0/0"] # 필요에 따라 제한적인 CIDR로 변경 가능

  # EKS 클러스터 관찰성 설정
  enable_cloudwatch_observability = true

  # 노드 그룹 설정
  node_group_name    = "tier3-nodegroup"
  node_instance_type = "t3.small" # 비용 효율적인 인스턴스 유형
  node_disk_size     = 20         # GB
  node_desired_size  = 3          # 노드 수
  node_min_size      = 2
  node_max_size      = 5

  # Auto Scaling 설정
  enable_autoscaling = true

  # 원격 상태 설정
  # 01-base-infra 상태 파일에서 정보 가져오기
  remote_state_backend = "s3"
  remote_state_bucket  = "terraform-state-tier3-123456"
  remote_state_key     = "tier3/01-base-infra/terraform.tfstate"
  remote_state_region  = "ap-northeast-2"

  # IRSA 관련 로컬 변수
  service_account_name = "myapp-sa"
  k8s_namespace        = "default"

  # ArgoCD 설정
  argocd_chart_version = "5.36.1"
  argocd_admin_password_hash = "$2a$10$mivhwttXM0U/pCVHBQ3MG.8G5DylCxRq8t7GJX4/X46vwbNoz91gi" # 안전한 방법으로 관리 필요
  
  # 인그레스 설정
  ingress_enabled = true
  argocd_ingress_host = "argocd.${local.domain_name}"
  ingress_class = "alb"
  ingress_annotations = {
    "alb.ingress.kubernetes.io/scheme" = "internet-facing"
    "alb.ingress.kubernetes.io/target-type" = "ip"
  }
  
  # 도메인 설정
  domain_name = "mydairy.my"
  zone_id = "Z01078892J4R7FP4HB44O" # aws route53 list-hosted-zones 명령어로 확인 혹은 콘솔에서 호스팅영역 ID 항목에서 확인
}
