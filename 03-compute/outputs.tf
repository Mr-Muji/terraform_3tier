#---------------------------------------
# EKS 클러스터 출력 변수 정의
#---------------------------------------

output "cluster_id" {
  description = "생성된 EKS 클러스터의 ID"
  value       = module.compute.cluster_id
}

output "cluster_endpoint" {
  description = "EKS 클러스터 API 서버 엔드포인트"
  value       = module.compute.cluster_endpoint
}

output "cluster_ca_data" {
  description = "EKS 클러스터 인증 기관 데이터"
  value       = module.compute.cluster_certificate_authority_data
}

output "eks_cluster_id" {
  description = "생성된 EKS 클러스터의 ID (별칭)"
  value       = module.compute.cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS 클러스터 API 서버 엔드포인트 (별칭)"
  value       = module.compute.cluster_endpoint
}

output "eks_cluster_ca_data" {
  description = "EKS 클러스터 인증 기관 데이터 (별칭)"
  value       = module.compute.cluster_certificate_authority_data
}

output "oidc_provider_url" {
  description = "EKS OIDC 공급자 URL"
  value       = module.compute.oidc_provider_url
}

output "oidc_provider_arn" {
  description = "EKS OIDC 공급자 ARN"
  value       = module.compute.oidc_provider_arn
}

output "kubernetes_provider_config" {
  description = "Kubernetes 프로바이더 구성을 위한 정보"
  value = {
    host                   = module.compute.cluster_endpoint
    cluster_ca_certificate = module.compute.cluster_certificate_authority_data
  }
  sensitive = true
}

#---------------------------------------
# IRSA 출력값
#---------------------------------------
output "irsa_role_arn" {
  description = "IRSA 역할 ARN"
  value       = module.irsa.role_arn
}

output "irsa_role_name" {
  description = "IRSA 역할 이름"
  value       = module.irsa.role_name
}

output "irsa_service_account_name" {
  description = "쿠버네티스 서비스 계정 이름"
  value       = module.irsa.service_account_name
}

# ArgoCD 관련 출력
output "argocd_namespace" {
  description = "ArgoCD가 설치된 네임스페이스"
  value       = module.argocd.argocd_namespace
}

output "argocd_url" {
  description = "ArgoCD 접속 URL"
  value       = module.argocd.argocd_url
}

output "argocd_server_service" {
  description = "ArgoCD 서버 서비스 이름"
  value       = module.argocd.argocd_server_service
}

output "argocd_hostname" {
  description = "ArgoCD 인그레스 호스트이름"
  value       = module.argocd.argocd_hostname
}

output "argocd_admin_password_hash" {
  description = "ArgoCD 관리자 비밀번호 해시"
  value       = module.argocd.admin_password_hash
  sensitive   = true
}

output "argocd_ingress_class" {
  description = "ArgoCD에 사용된 인그레스 클래스"
  value       = module.argocd.ingress_class
}

output "argocd_ingress_annotations" {
  description = "ArgoCD에 사용된 인그레스 어노테이션"
  value       = module.argocd.ingress_annotations
}

output "argocd_chart_version" {
  description = "설치된 ArgoCD 차트 버전"
  value       = module.argocd.argocd_chart_version
}

output "argocd_is_installed" {
  description = "ArgoCD 설치 여부"
  value       = module.argocd.is_installed
}
