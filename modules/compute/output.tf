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
  description = "쿠버네티스 API 서버 엔드포인트"
  value       = aws_eks_cluster.this.endpoint
}

# 클러스터 인증서 데이터
output "cluster_certificate_authority_data" {
  description = "클러스터와 통신하는 데 필요한 인증 기관 인증서 데이터"
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