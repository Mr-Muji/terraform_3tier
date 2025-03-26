# AWS Secrets Manager에서 Jenkins 관련 시크릿 가져오기
data "aws_secretsmanager_secret" "jenkins" {
  count = var.jenkins_secret_arn != "" ? 1 : 0
  arn   = var.jenkins_secret_arn
}

data "aws_secretsmanager_secret_version" "jenkins" {
  count     = var.jenkins_secret_arn != "" ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.jenkins[0].id
}

# GitHub 토큰 시크릿 가져오기 추가
data "aws_secretsmanager_secret" "github" {
  count = var.github_token_secret_arn != "" ? 1 : 0
  arn   = var.github_token_secret_arn
}

data "aws_secretsmanager_secret_version" "github" {
  count     = var.github_token_secret_arn != "" ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.github[0].id
}

locals {
  # Jenkins 시크릿 처리
  jenkins_secrets = var.jenkins_secret_arn != "" ? jsondecode(data.aws_secretsmanager_secret_version.jenkins[0].secret_string) : {}
  admin_password = lookup(local.jenkins_secrets, "admin_password", var.jenkins_admin_password)
  
  # GitHub 토큰 처리
  github_secrets = var.github_token_secret_arn != "" ? jsondecode(data.aws_secretsmanager_secret_version.github[0].secret_string) : {}
  github_token = lookup(local.github_secrets, "token", "")
}

# Jenkins 관리자 비밀번호 Secret
resource "kubernetes_secret" "jenkins_admin" {
  metadata {
    name      = "jenkins-admin"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }

  data = {
    "jenkins-admin-password" = local.admin_password
    "jenkins-admin-user"     = "admin"
  }

  type = "Opaque"
}

# GitHub 토큰을 위한 Secret - 이제 AWS Secrets Manager에서 값을 가져옴
resource "kubernetes_secret" "github_token" {
  metadata {
    name      = "github-token"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }

  data = {
    "github-token" = local.github_token  # 직접 변수가 아닌 AWS에서 가져온 값 사용
  }

  type = "Opaque"
}

# AWS 자격 증명을 위한 Secret
resource "kubernetes_secret" "aws_credentials" {
  metadata {
    name      = "aws-credentials"  # 시크릿 이름
    namespace = kubernetes_namespace.jenkins.metadata[0].name  # Jenkins 네임스페이스
  }

  data = {
    "aws-access-key" = lookup(local.jenkins_secrets, "aws_access_key", "")  # AWS 접근 키
    "aws-secret-key" = lookup(local.jenkins_secrets, "aws_secret_key", "")  # AWS 시크릿 키
  }

  type = "Opaque"  # 일반 시크릿 타입
}

# Docker Hub 자격 증명을 위한 Secret (필요한 경우)
resource "kubernetes_secret" "dockerhub" {
  metadata {
    name      = "dockerhub-credentials"  # 시크릿 이름
    namespace = kubernetes_namespace.jenkins.metadata[0].name  # Jenkins 네임스페이스
  }

  data = {
    "username" = lookup(local.jenkins_secrets, "dockerhub_username", "")  # Docker Hub 사용자명
    "password" = lookup(local.jenkins_secrets, "dockerhub_password", "")  # Docker Hub 비밀번호
  }

  type = "Opaque"  # 일반 시크릿 타입
}