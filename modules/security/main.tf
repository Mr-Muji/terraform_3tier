#---------------------------------------
# 웹 계층 보안 그룹
# 웹 애플리케이션과 외부 로드 밸런서에 적용되는 보안 규칙
#---------------------------------------
resource "aws_security_group" "web_sg" {
  name        = "SG_web_${var.project_name}"
  description = "Security group for web tier - Controls traffic to/from web servers and load balancers"
  vpc_id      = var.vpc_id

  # 인터넷에서 들어오는 HTTP 트래픽 허용 (포트 80)
  # 웹 서비스에 대한 일반 HTTP 접근을 허용합니다
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 모든 IP 주소에서 접근 허용
    description = "Allow HTTP traffic from internet - Required for web access"
  }

  # 인터넷에서 들어오는 HTTPS 트래픽 허용 (포트 443)
  # 보안 웹 서비스에 대한 암호화된 HTTPS 접근을 허용합니다
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 모든 IP 주소에서 접근 허용
    description = "Allow HTTPS traffic from internet - Required for secure web access"
  }

  # 모든 아웃바운드 트래픽 허용
  # 웹 서버에서 외부 서비스(예: 업데이트, API 호출)에 접근할 수 있도록 허용합니다
  egress {
    from_port   = 0      # 모든 포트
    to_port     = 0      # 모든 포트
    protocol    = "-1"   # 모든 프로토콜
    cidr_blocks = ["0.0.0.0/0"]  # 모든 IP 주소로 접근 허용
    description = "Allow all outbound traffic - Required for software updates and external API calls"
  }

  # 리소스 식별 및 관리를 위한 태그 추가
  tags = {
    Name        = "SG_web_${var.project_name}"  # 식별을 위한 명확한 이름
    Environment = var.environment               # 환경 구분 (dev, staging, prod)
    Tier        = "Web"                         # 아키텍처 계층 정보
    ManagedBy   = "Terraform"                   # 관리 도구 정보
  }

  # 보안 그룹 변경 시 적용 전 대기 시간 설정
  # 이는 의존성 있는 리소스 업데이트 시 오류 방지에 도움이 됩니다
  lifecycle {
    create_before_destroy = true
  }
}

#---------------------------------------
# 애플리케이션 계층 보안 그룹
# 애플리케이션 서버와 컨테이너에 적용되는 보안 규칙
#---------------------------------------
resource "aws_security_group" "app_sg" {
  name        = "SG_app_${var.project_name}"
  description = "Security group for application tier - Controls traffic to/from application servers and containers"
  vpc_id      = var.vpc_id

  # 웹 계층에서 들어오는 애플리케이션 포트 트래픽 허용 (포트 8080)
  # 웹 서버가 애플리케이션 서버의 API나 서비스에 접근할 수 있도록 허용합니다
  ingress {
    from_port       = 8080                          # 애플리케이션 서버 포트
    to_port         = 8080                          # 애플리케이션 서버 포트
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]  # 웹 티어 보안 그룹에서만 접근 허용
    description     = "Allow traffic from web tier to application servers - Required for web-to-app communication"
  }

  # 추가: 애플리케이션 계층 내부 통신 허용
  # 마이크로서비스 아키텍처에서 서비스 간 통신에 필요합니다
  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    self            = true  # 동일 보안 그룹 내 리소스 간 통신 허용
    description     = "Allow internal communication between application components - Required for microservices"
  }

  # 모든 아웃바운드 트래픽 허용
  # 애플리케이션 서버에서 외부 서비스나 데이터베이스에 접근할 수 있도록 허용합니다
  egress {
    from_port   = 0      # 모든 포트
    to_port     = 0      # 모든 포트
    protocol    = "-1"   # 모든 프로토콜
    cidr_blocks = ["0.0.0.0/0"]  # 모든 IP 주소로 접근 허용
    description = "Allow all outbound traffic - Required for database connections and external API calls"
  }

  # 리소스 식별 및 관리를 위한 태그 추가
  tags = {
    Name        = "SG_app_${var.project_name}"  # 식별을 위한 명확한 이름
    Environment = var.environment               # 환경 구분 (dev, staging, prod)
    Tier        = "Application"                 # 아키텍처 계층 정보
    ManagedBy   = "Terraform"                   # 관리 도구 정보
  }

  # 보안 그룹 변경 시 적용 전 대기 시간 설정
  lifecycle {
    create_before_destroy = true
  }
}

#---------------------------------------
# 데이터베이스 계층 보안 그룹
# 데이터베이스 서버에 적용되는 보안 규칙
#---------------------------------------
resource "aws_security_group" "db_sg" {
  name        = "SG_db_${var.project_name}"
  description = "Security group for database tier - Controls traffic to/from database servers"
  vpc_id      = var.vpc_id

  # 애플리케이션 계층에서 들어오는 MySQL/Aurora 트래픽 허용 (포트 3306)
  # 애플리케이션 서버가 데이터베이스에 접근할 수 있도록 허용합니다
  ingress {
    from_port       = 3306                          # MySQL/Aurora 포트
    to_port         = 3306                          # MySQL/Aurora 포트
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]  # 애플리케이션 티어 보안 그룹에서만 접근 허용
    description     = "Allow MySQL traffic from application tier - Required for app-to-database communication"
  }

  # 데이터베이스 복제 및 백업을 위한 추가 포트 허용 (필요한 경우)
  # 복제 및 백업을 위한 내부 통신에 필요합니다
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    self            = true  # 동일 보안 그룹 내 리소스 간 통신 허용
    description     = "Allow database replication traffic - Required for high availability setup"
  }

  # 모든 아웃바운드 트래픽 허용
  # 데이터베이스 서버에서 업데이트 등을 위한 외부 접근을 허용합니다
  egress {
    from_port   = 0      # 모든 포트
    to_port     = 0      # 모든 포트
    protocol    = "-1"   # 모든 프로토콜
    cidr_blocks = ["0.0.0.0/0"]  # 모든 IP 주소로 접근 허용
    description = "Allow all outbound traffic - Required for software updates and patch management"
  }

  # 리소스 식별 및 관리를 위한 태그 추가
  tags = {
    Name        = "SG_db_${var.project_name}"  # 식별을 위한 명확한 이름
    Environment = var.environment              # 환경 구분 (dev, staging, prod)
    Tier        = "Database"                   # 아키텍처 계층 정보
    ManagedBy   = "Terraform"                  # 관리 도구 정보
  }

  # 보안 그룹 변경 시 적용 전 대기 시간 설정
  lifecycle {
    create_before_destroy = true
  }
}


#---------------------------------------
# 선택적: 추가 보안 그룹 - 기타 서비스용
# 필요에 따라 추가 서비스를 위한 보안 그룹을 확장할 수 있습니다
#---------------------------------------
# 예를 들어, Redis 캐시 서버용 보안 그룹
# resource "aws_security_group" "cache_sg" {
#   name        = "SG_cache_${var.project_name}"
#   description = "Security group for cache instances (Redis, ElastiCache)"
#   vpc_id      = var.vpc_id

#   # 애플리케이션 계층에서 들어오는 Redis 트래픽 허용 (포트 6379)
#   ingress {
#     from_port       = 6379                          # Redis 기본 포트
#     to_port         = 6379
#     protocol        = "tcp"
#     security_groups = [aws_security_group.app_sg.id]
#     description     = "Allow Redis traffic from application tier"
#   }

#   # 모든 아웃바운드 트래픽 허용
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow all outbound traffic"
#   }

#   tags = {
#     Name        = "SG_cache_${var.project_name}"
#     Environment = var.environment
#     Tier        = "Cache"
#     ManagedBy   = "Terraform"
#   }
# }

# ECR 접근을 위한 정책 생성
resource "aws_iam_policy" "ecr_access_policy" {
  name        = "${var.project_name}-ecr-access-policy"
  description = "ECR 저장소에 대한 접근 권한 정책"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}