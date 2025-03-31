#---------------------------------------
# 프로바이더 및 Terraform 버전 요구사항
#---------------------------------------
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

# common 원격 상태 데이터 소스 추가
data "terraform_remote_state" "common" {
  backend = "s3"
  
  config = {
    bucket = "s3-3tier-terraform-state"
    key    = "3tier/common/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

# 공통 공급자 설정
provider "aws" {
  region = data.terraform_remote_state.common.outputs.aws_region
  
  default_tags {
    tags = data.terraform_remote_state.common.outputs.common_tags
  }
}

# prerequisites 원격 상태 데이터 소스 추가
data "terraform_remote_state" "prerequisites" {
  backend = "s3"
  
  config = {
    bucket = data.terraform_remote_state.common.outputs.remote_state_bucket
    key    = "3tier/prerequisites/terraform.tfstate"
    region = data.terraform_remote_state.common.outputs.remote_state_region
  }
}

# 이전 상태 파일에서 정보 가져오기
data "terraform_remote_state" "base_infra" {
  backend = "s3"
  
  config = {
    bucket = data.terraform_remote_state.common.outputs.remote_state_bucket
    key    = "3tier/base-infra/terraform.tfstate"
    region = data.terraform_remote_state.common.outputs.remote_state_region
  }
}

# 클러스터 접근을 위한 로컬 변수
locals {
  # EKS 클러스터가 존재하는지 확인
  eks_cluster_exists = can(module.compute.cluster_id) && can(module.compute.cluster_endpoint)
  
  # 안전한 값 구성
  safe_cluster_endpoint = local.eks_cluster_exists ? module.compute.cluster_endpoint : "https://localhost:8443"
  safe_cluster_ca_cert = local.eks_cluster_exists ? base64decode(module.compute.cluster_certificate_authority_data) : null
  safe_cluster_id = local.eks_cluster_exists ? module.compute.cluster_id : "dummy-cluster"
}

# Kubernetes 프로바이더 설정
provider "kubernetes" {
  host                   = local.safe_cluster_endpoint
  cluster_ca_certificate = local.safe_cluster_ca_cert
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", local.safe_cluster_id, "--region", data.terraform_remote_state.common.outputs.aws_region]
  }
}

# Helm 프로바이더 설정
provider "helm" {
  kubernetes {
    host                   = local.safe_cluster_endpoint
    cluster_ca_certificate = local.safe_cluster_ca_cert
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", local.safe_cluster_id, "--region", local.aws_region]
    }
  }
}


