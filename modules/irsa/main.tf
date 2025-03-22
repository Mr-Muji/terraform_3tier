/**
 * IRSA(IAM Roles for Service Accounts) 설정 모듈
 * EKS 서비스 계정이 AWS 서비스(Secrets Manager 등)에 안전하게 접근할 수 있도록 설정합니다.
 */

# 기존 IAM 역할이 존재하는지 확인
resource "null_resource" "check_role_exists" {
  provisioner "local-exec" {
    command = "aws iam get-role --role-name ${var.prefix}-${var.service_account_name}-role || echo 'Role does not exist' > /dev/null"
    on_failure = continue
  }
}

# IAM 역할 생성
resource "aws_iam_role" "eks_sa_role" {
  name               = "${var.prefix}-${var.service_account_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.eks_oidc_provider_url, "https://", "")}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(var.eks_oidc_provider_url, "https://", "")}:sub": "system:serviceaccount:${var.k8s_namespace}:${var.service_account_name}",
            "${replace(var.eks_oidc_provider_url, "https://", "")}:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-${var.service_account_name}-role"
  })
}

# 현재 AWS 계정 정보 가져오기
data "aws_caller_identity" "current" {}

# 정책 첨부
resource "aws_iam_role_policy_attachment" "policy_attachment" {
  count      = length(var.policy_arns)
  role       = aws_iam_role.eks_sa_role.name
  policy_arn = var.policy_arns[count.index]
}

# Kubernetes 서비스 계정 생성 (Terraform kubernetes 프로바이더 설정 필요)
resource "kubernetes_service_account" "service_account" {
  count = 0 # var.create_k8s_service_account ? 1 : 0
  
  metadata {
    name      = var.service_account_name
    namespace = var.k8s_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_sa_role.arn
    }
  }
  
  automount_service_account_token = true
}