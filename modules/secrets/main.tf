/**
 * AWS Secrets Manager를 위한 모듈
 * 데이터베이스 자격 증명을 안전하게 저장하고 관리합니다.
 */

# 고정된 이름에 사용할 랜덤 문자열 생성 (한 번 생성 후 유지)
resource "random_string" "secret_suffix" {
  length  = 8
  special = false
  upper   = false
}

# KMS 키 생성 (시크릿 암호화용)
resource "aws_kms_key" "secrets" {
  description             = "KMS key for DB secrets encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-secrets-kms-key"
  })
}

# KMS 키 별칭 설정
resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.prefix}-secrets-key"
  target_key_id = aws_kms_key.secrets.key_id
}

# MySQL DB 시크릿 생성
resource "aws_secretsmanager_secret" "mysql" {
  name        = "${var.prefix}/db/mysql-${random_string.secret_suffix.result}" # 랜덤 문자열로 고정된 이름 사용
  description = "MySQL database credentials"
  kms_key_id  = aws_kms_key.secrets.arn
  
  # 복구 윈도우 설정 (개발 환경용)
  recovery_window_in_days = 0
  
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-mysql-secret"
  })
}

# 시크릿 값 설정
resource "aws_secretsmanager_secret_version" "mysql" {
  secret_id = aws_secretsmanager_secret.mysql.id
  
  # JSON 형식으로 여러 시크릿 값을 하나의 시크릿에 저장
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    dbname   = var.db_name
    engine   = "mysql"
    port     = 3306
  })
}

# GitHub 토큰 시크릿 생성
resource "aws_secretsmanager_secret" "github" {
  name        = "${var.prefix}/github/token-${random_string.secret_suffix.result}"
  description = "GitHub access token for repository operations(argocd manifest repo)"
  kms_key_id  = aws_kms_key.secrets.arn
  
  # 복구 윈도우 설정 (개발 환경용)
  recovery_window_in_days = 0
  
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-github-token-secret"
  })
}

# GitHub 토큰 값 설정
resource "aws_secretsmanager_secret_version" "github" {
  secret_id = aws_secretsmanager_secret.github.id
  
  # 항상 빈 객체라도 생성
  secret_string = jsonencode({
    token = var.github_token != "" ? var.github_token : "dummy-token"
  })
}

# Jenkins 관련 시크릿 생성
resource "aws_secretsmanager_secret" "jenkins" {
  name        = "${var.prefix}/jenkins/credentials-${random_string.secret_suffix.result}"
  description = "Jenkins credentials and sensitive variables"
  kms_key_id  = aws_kms_key.secrets.arn
  
  recovery_window_in_days = 0
  
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-jenkins-secrets"
  })
}

# Jenkins 시크릿 값 설정
resource "aws_secretsmanager_secret_version" "jenkins" {
  secret_id = aws_secretsmanager_secret.jenkins.id
  
  # 기본값 제공
  secret_string = jsonencode({
    admin_password    = var.jenkins_admin_password != "" ? var.jenkins_admin_password : "admin123"
    aws_access_key    = var.aws_access_key != "" ? var.aws_access_key : ""
    aws_secret_key    = var.aws_secret_key != "" ? var.aws_secret_key : ""
    dockerhub_username = var.dockerhub_username != "" ? var.dockerhub_username : ""
    dockerhub_password = var.dockerhub_password != "" ? var.dockerhub_password : "" 
  })
}

# EKS 클러스터에 시크릿 접근을 위한 IAM 정책
resource "aws_iam_policy" "secrets_access" {
  name        = "${var.prefix}-secrets-access-policy"
  description = "Allow access to Secrets Manager secrets for EKS workloads"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = [
          aws_secretsmanager_secret.mysql.arn,
          aws_secretsmanager_secret.github.arn,
          aws_secretsmanager_secret.jenkins.arn
        ]
      },
      {
        Effect   = "Allow",
        Action   = [
          "kms:Decrypt"
        ],
        Resource = [
          aws_kms_key.secrets.arn
        ]
      }
    ]
  })
}

# EKS 서비스 계정이 있는 경우, 정책 연결
resource "aws_iam_role_policy_attachment" "secrets_access" {
  count      = var.eks_node_role_name != "" ? 1 : 0
  role       = var.eks_node_role_name
  policy_arn = aws_iam_policy.secrets_access.arn
}