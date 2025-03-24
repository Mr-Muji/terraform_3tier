#---------------------------------------
# Terraform 설정
#---------------------------------------
terraform {
  # 필요한 공급자(provider) 정의
  required_providers {
    aws = {
      source  = "hashicorp/aws" # AWS 공급자의 소스 위치
      version = ">= 4.0.0"      # AWS 공급자 버전 (4.x 버전 사용)
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10.0"

      configuration_aliases = [kubernetes.post_cluster]
    }
    # TLS 프로바이더 추가 - EKS OIDC 발급자의 인증서를 처리하는 데 사용됩니다
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0.0"
    }
    # Helm 프로바이더 추가 - Kubernetes 애플리케이션 배포를 위한 패키지 관리자
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.5.0"
    }
    # Null 프로바이더 추가 - 로컬 명령어 실행 및 임시 리소스용
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.1.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.7.0"
    }
  }
  # Terraform 최소 버전 요구사항
  required_version = ">= 1.0.0" # Terraform 1.0.0 이상 필요
}

#---------------------------------------
# AWS 공급자 설정
#---------------------------------------
provider "aws" {
  region = var.aws_region # variables.tf에 정의된 AWS 리전 사용

  # 모든 리소스에 기본적으로 적용될 태그 설정
  default_tags {
    tags = {
      ManagedBy = "Terraform" # 이 리소스가 Terraform으로 관리됨을 표시
      Project   = "tier3"     # 프로젝트 이름 (모든 리소스 공통)
      # 환경별 태그는 tfvars 파일이나 환경 변수로 추가 가능
    }
  }

  # 추가 공급자 옵션:
  # profile = "default"     # AWS 프로필 지정 (필요 시 주석 해제)
  # assume_role { ... }     # 다른 계정의 역할 수임 (필요 시 구성)
}

# 계획 시에만 사용할 기본 Provider (더미 설정)
provider "kubernetes" {
  # 더미 구성으로 초기화만 가능하게 함
  host = "https://localhost:8443"
  insecure = true
}

# 안전한 접근을 위해 condition 추가
locals {
  # EKS 클러스터가 존재하는지 확인
  eks_cluster_exists = can(module.compute.cluster_id) && can(module.compute.cluster_endpoint) && can(module.compute.cluster_certificate_authority_data)
  
  # 안전한 클러스터 엔드포인트 
  safe_cluster_endpoint = local.eks_cluster_exists ? module.compute.cluster_endpoint : "https://localhost:8443"
  
  # 안전한 클러스터 CA 인증서
  safe_cluster_ca_cert = local.eks_cluster_exists ? base64decode(module.compute.cluster_certificate_authority_data) : null
  
  # 안전한 클러스터 이름
  safe_cluster_name = local.eks_cluster_exists ? module.compute.cluster_id : "dummy-cluster"
}

# 쿠버네티스 프로바이더 - EKS 클러스터가 생성된 후에만 활성화
provider "kubernetes" {
  alias = "post_cluster"  # 쿠베 문제용

  host                   = local.safe_cluster_endpoint
  cluster_ca_certificate = local.safe_cluster_ca_cert
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks", 
      "get-token", 
      "--cluster-name", 
      local.safe_cluster_name, 
      "--region", 
      var.aws_region
    ]
  }
}
# 쿠베 문제용
# provider "helm" {
#   kubernetes {
#     host = "https://localhost:8443"
#     insecure = true
#   }
# }
#---------------------------------------
# Helm Provider 설정
#---------------------------------------
# Helm 프로바이더 - EKS 클러스터가 생성된 후에만 활성화
provider "helm" {
  kubernetes {
    host                   = local.safe_cluster_endpoint
    cluster_ca_certificate = local.safe_cluster_ca_cert
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        local.safe_cluster_name,
        "--region",
        var.aws_region
      ]
    }
  }
}
