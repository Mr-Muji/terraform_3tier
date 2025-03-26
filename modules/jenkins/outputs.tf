# Jenkins 모듈 출력 정의

output "jenkins_namespace" {
  description = "Jenkins Kubernetes 네임스페이스"
  value       = kubernetes_namespace.jenkins.metadata[0].name
}

output "jenkins_service_account" {
  description = "Jenkins 서비스 계정 이름"
  value       = kubernetes_service_account.jenkins.metadata[0].name
}

output "jenkins_iam_role_arn" {
  description = "Jenkins 서비스 계정에 연결된 IAM 역할 ARN"
  value       = aws_iam_role.jenkins_role.arn
}

output "jenkins_url" {
  description = "Jenkins 접속 URL"
  value       = var.ingress_enabled ? "https://${var.ingress_host}" : "kubectl port-forward svc/jenkins -n ${kubernetes_namespace.jenkins.metadata[0].name} 8080:8080"
}

output "jenkins_admin_user" {
  description = "Jenkins 관리자 사용자 이름"
  value       = var.jenkins_admin_user
}

output "jenkins_admin_password" {
  description = "Jenkins 관리자 비밀번호 확인 방법"
  value       = "기본 비밀번호는 변수로 설정되었습니다. 필요한 경우 Helm 명령어를 사용하여 확인하세요."
  sensitive   = true
}
