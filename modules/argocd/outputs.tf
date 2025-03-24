#-------------------------------------------------------
# ArgoCD 모듈 출력 값
#-------------------------------------------------------

output "argocd_namespace" {
  description = "ArgoCD가 설치된 네임스페이스"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_server_service" {
  description = "ArgoCD 서버 서비스 이름"
  value       = "argocd-server"
}

output "argocd_url" {
  description = "ArgoCD 접속 URL"
  value       = var.ingress_enabled ? "https://${var.ingress_host}" : "https://localhost:8080/api/v1/namespaces/${kubernetes_namespace.argocd.metadata[0].name}/services/argocd-server:https/port-forward"
}

output "argocd_hostname" {
  description = "ArgoCD 인그레스 호스트이름"
  value       = try(
    data.kubernetes_ingress_v1.argocd_ingress[0].status[0].load_balancer[0].ingress[0].hostname,
    "argocd.${var.domain_name}" 
  )
}

# 추가 출력 - 04-cicd-apps에서 필요한 정보
output "admin_password_hash" {
  description = "ArgoCD 관리자 비밀번호 해시"
  value       = var.argocd_admin_password_hash
  sensitive   = true
}

output "ingress_class" {
  description = "사용된 인그레스 클래스"
  value       = var.ingress_class
}

output "ingress_annotations" {
  description = "사용된 인그레스 어노테이션"
  value       = var.ingress_annotations
}

output "argocd_chart_version" {
  description = "설치된 ArgoCD 차트 버전"
  value       = var.argocd_chart_version
}

output "is_installed" {
  description = "ArgoCD 설치 여부"
  value       = true
} 