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

# Kubernetes Provider 설정
provider "kubernetes" {
  host                   = module.compute.cluster_endpoint
  cluster_ca_certificate = base64decode(module.compute.cluster_certificate_authority_data)

  # AWS 인증 사용 (aws-cli 통해 인증)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.compute.cluster_id,
      "--region",
      var.region
    ]
  }
}

#---------------------------------------
# Helm Provider 설정
#---------------------------------------
provider "helm" {
  kubernetes {
    # EKS 클러스터의 API 서버 엔드포인트를 사용하여 연결합니다
    host                   = module.compute.cluster_endpoint
    
    # 클러스터 인증서를 사용하여 TLS 통신을 검증합니다
    # base64로 인코딩된 인증서를 디코딩합니다
    cluster_ca_certificate = base64decode(module.compute.cluster_certificate_authority_data)
    
    # AWS EKS 인증 방식을 사용합니다
    # aws-cli를 통해 EKS 토큰을 가져옵니다
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.compute.cluster_id,
        "--region",
        var.region
      ]
    }
  }
}
