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

output "installed" {
  description = "ArgoCD 설치 완료 여부"
  value       = true
  depends_on  = [helm_release.argocd, time_sleep.wait_for_crds]
}
