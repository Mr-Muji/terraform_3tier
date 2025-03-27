#---------------------------------------
# 프로바이더 설정
# AWS, Kubernetes 프로바이더 구성
#---------------------------------------
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
}

# AWS 프로바이더 설정
provider "aws" {
  region = local.aws_region
}

# 01-base-infra에서 상태 정보 가져오기
data "terraform_remote_state" "base_infra" {
  backend = "s3"
  config = {
    bucket = local.remote_state_bucket
    key    = "tier3/01-base-infra/terraform.tfstate"
    region = local.remote_state_region
  }
}

# 03-compute에서 상태 정보 가져오기
data "terraform_remote_state" "compute" {
  backend = "s3"
  config = {
    bucket = local.remote_state_bucket
    key    = "tier3/03-compute/terraform.tfstate"
    region = local.remote_state_region
  }
}

# 00-prerequisites에서 ECR 정보 가져오기
data "terraform_remote_state" "prerequisites" {
  backend = "s3"
  config = {
    bucket = local.remote_state_bucket
    key    = "tier3/00-prerequisites/terraform.tfstate"
    region = local.remote_state_region
  }
}

# 02-database 모듈에서 상태 정보 가져오기
data "terraform_remote_state" "database" {
  backend = "s3"
  config = {
    bucket = local.remote_state_bucket
    key    = "tier3/02-database/terraform.tfstate"
    region = local.remote_state_region
  }
}

# ECR 인증 토큰 가져오기
data "aws_ecr_authorization_token" "token" {
  registry_id = data.aws_caller_identity.current.account_id
}

# 현재 AWS 계정 정보 가져오기
data "aws_caller_identity" "current" {}

# 클러스터 존재 여부 확인을 위한 로직
locals {
  eks_cluster_exists = can(data.terraform_remote_state.compute.outputs.eks_cluster_id) && can(data.terraform_remote_state.compute.outputs.eks_cluster_endpoint)
  
  # 안전한 값 구성
  safe_cluster_endpoint = local.eks_cluster_exists ? data.terraform_remote_state.compute.outputs.eks_cluster_endpoint : "https://localhost:8443"
  safe_cluster_ca_cert = local.eks_cluster_exists ? base64decode(data.terraform_remote_state.compute.outputs.eks_cluster_ca_data) : null
  safe_cluster_id = local.eks_cluster_exists ? data.terraform_remote_state.compute.outputs.eks_cluster_id : "dummy-cluster"
}

# Kubernetes 프로바이더 설정
provider "kubernetes" {
  host                   = local.safe_cluster_endpoint
  cluster_ca_certificate = local.safe_cluster_ca_cert
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", local.safe_cluster_id, "--region", local.aws_region]
  }
}

# Helm 프로바이더 설정 (필요한 경우)
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

