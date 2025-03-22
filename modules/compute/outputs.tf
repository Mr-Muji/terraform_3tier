# 클러스터 ID
output "cluster_id" {
  description = "생성된 EKS 클러스터의 ID"
  value       = aws_eks_cluster.this.id
}

# 클러스터 ARN
output "cluster_arn" {
  description = "EKS 클러스터의 ARN"
  value       = aws_eks_cluster.this.arn
}

# 클러스터 엔드포인트
output "cluster_endpoint" {
  description = "EKS 클러스터 API 서버 엔드포인트"
  value       = aws_eks_cluster.this.endpoint
}

# 클러스터 인증서 데이터
output "cluster_certificate_authority_data" {
  description = "EKS 클러스터 CA 인증서 데이터"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

# 클러스터 IAM 역할 ARN
output "cluster_role_arn" {
  description = "EKS 클러스터 IAM 역할 ARN"
  value       = aws_iam_role.cluster.arn
}

# 노드 IAM 역할 ARN
output "node_role_arn" {
  description = "EKS 노드 IAM 역할 ARN"
  value       = aws_iam_role.node.arn
}

# 노드 그룹 ARN
output "node_group_arn" {
  description = "EKS 노드 그룹 ARN"
  value       = aws_eks_node_group.general_purpose.arn
}

# 노드 그룹 이름
output "node_group_name" {
  description = "EKS 노드 그룹 이름"
  value       = aws_eks_node_group.general_purpose.node_group_name
}

# 노드 그룹 상태
output "node_group_status" {
  description = "EKS 노드 그룹 상태"
  value       = aws_eks_node_group.general_purpose.status
}

# 생성된 네임스페이스
output "kubernetes_namespace" {
  description = "생성된 Kubernetes 네임스페이스"
  value       = kubernetes_namespace.backend.metadata[0].name
}

# OIDC 프로바이더 ARN
output "oidc_provider_arn" {
  description = "EKS 클러스터의 OIDC 프로바이더 ARN - IAM 역할 신뢰 관계에서 사용됩니다"
  value       = aws_iam_openid_connect_provider.eks.arn
}

# OIDC 프로바이더 URL
output "oidc_provider_url" {
  description = "EKS 클러스터의 OIDC 발급자 URL - IAM 역할 조건에서 사용됩니다"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# Load Balancer Controller 역할 ARN
output "lb_controller_role_arn" {
  description = "AWS Load Balancer Controller에 사용되는 IAM 역할 ARN"
  value       = aws_iam_role.lb_controller.arn
}