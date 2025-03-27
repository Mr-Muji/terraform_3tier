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
  node_instance_type = "t3.medium" # 비용 효율적인 인스턴스 유형
  node_disk_size     = 20         # GB
  node_desired_size  = 3          # 노드 수
  node_min_size      = 2
  node_max_size      = 3

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
  
  # 인그레스 공통 설정
  ingress_annotations = {
    "alb.ingress.kubernetes.io/scheme" = "internet-facing"
    "alb.ingress.kubernetes.io/target-type" = "ip"
  }
  
  # 도메인 설정
  domain_name = "mydairy.my"
  zone_id     = "Z01078892J4R7FP4HB44O"  # Route53 호스팅 존 ID

  # ArgoCD 전용 인그레스 설정
  argocd_ingress_enabled = true
  argocd_ingress_class = "alb"  # ArgoCD 전용 인그레스 클래스
  argocd_ingress_host = "argocd.${local.domain_name}"
  
  # Jenkins 전용 인그레스 설정
  jenkins_ingress_enabled = true
  jenkins_ingress_class = "alb"  # Jenkins 전용 인그레스 클래스
  jenkins_ingress_host = "jenkins.${local.domain_name}"

  # Jenkins 관련 설정
  jenkins_namespace = "jenkins"
  jenkins_pvc_size = "8Gi"
  storage_class_name = "fucking-storage-class"
  
  # Secrets Manager에서 Jenkins 관리자 비밀번호 가져오기
  jenkins_admin_password = try(data.terraform_remote_state.base_infra.outputs.jenkins_admin_password, "admin123")
  
  # Jenkins 서비스 노출 설정
  jenkins_service_type = "ClusterIP" # 또는 "LoadBalancer"
  jenkins_service_port = 8080
  jenkins_agent_port = 50000
  
  # Jenkins 리소스 설정
  jenkins_cpu_request = "500m"
  jenkins_cpu_limit = "1000m"
  jenkins_memory_request = "1Gi"
  jenkins_memory_limit = "2Gi"
  
  # Jenkins 초기 플러그인 설치 여부
  jenkins_install_plugins = true
  
  # Jenkins RBAC 설정
  create_jenkins_service_account = true
  
  # Jenkins 스토리지 설정
  jenkins_persistence_enabled = true
  
  # Jenkins Helm 차트 설정
  jenkins_chart_version = "4.11.1" # ArgoCD와 동일한 Helm 차트 버전으로 통일
  
  # Jenkins 에이전트 설정
  jenkins_agent_image = "jenkins/inbound-agent:latest"
  jenkins_agent_working_dir = "/home/jenkins/agent"

  # ECR 관련 설정 (00-prerequisites에서 가져옴)
  backend_ecr_url  = data.terraform_remote_state.prerequisites.outputs.backend_ecr_url
  backend_ecr_name = data.terraform_remote_state.prerequisites.outputs.backend_ecr_name
  
  # 백엔드 레포지토리 설정
  backend_repo_url    = "https://github.com/Mr-Muji/3tier-backend.git"  # 백엔드 레포지토리 URL
  backend_repo_org    = "Mr-Muji"  # GitHub 조직 이름
  backend_repo_branch = "main"  # 기본 브랜치
  jenkins_job_suffix  = "pipeline"  # 작업 이름 접미사
  job_description     = "백엔드 애플리케이션 빌드 및 ECR 배포 파이프라인"  # 작업 설명
  scm_poll_interval   = "H/3 * * * *"  # 3분마다 SCM 폴링

}
