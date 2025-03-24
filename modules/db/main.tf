/**
 * MySQL DB 인스턴스 생성을 위한 메인 설정 파일
 * AWS RDS를 활용하여 A존에 MySQL 데이터베이스를 배포합니다.
 * AWS Secrets Manager에서 자격 증명을 가져와 사용합니다.
 */

# AWS Secrets Manager에서 데이터베이스 보안 정보 가져오기
data "aws_secretsmanager_secret" "mysql_secret" {
  arn = var.mysql_secret_arn
}

data "aws_secretsmanager_secret_version" "mysql_secret_version" {
  secret_id = data.aws_secretsmanager_secret.mysql_secret.id
}

locals {
  # JSON 형식의 시크릿을 파싱하여 데이터베이스 정보 추출
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.mysql_secret_version.secret_string)
}

# 데이터베이스 인스턴스 파라미터 그룹 (최소 설정)
resource "aws_db_parameter_group" "mysql" {
  name        = "${var.prefix}-mysql-params"
  family      = "mysql8.0"  # MySQL 8.0 기반
  description = "Minimized MySQL parameters"

  # 최소한의 필수 파라미터만 설정
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  tags = var.common_tags
}

# 데이터베이스 서브넷 그룹
resource "aws_db_subnet_group" "mysql" {
  name       = "${var.prefix}-mysql-subnet-group"
  subnet_ids = var.subnet_ids
  
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-mysql-subnet-group"
  })
}

# 데이터베이스 보안 그룹
resource "aws_security_group" "mysql" {
  name        = "${var.prefix}-mysql-sg"
  description = "Security group for MySQL database"
  vpc_id      = var.vpc_id
  
  # MySQL 포트 3306 접근 허용 (EKS 노드로부터만)
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_node_security_group_id]
    description     = "Allow MySQL traffic from EKS nodes"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = merge(var.common_tags, {
    Name = "mysql-${var.prefix}-sg"
  })
}

# RDS MySQL 인스턴스 (최소 스펙)
resource "aws_db_instance" "mysql" {
  identifier        = "mysql-${var.prefix}"
  engine            = "mysql"
  engine_version    = var.mysql_version
  instance_class    = var.db_instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  
  # 시크릿 매니저에서 가져온 정보 사용
  db_name  = local.db_credentials.dbname
  username = local.db_credentials.username
  password = local.db_credentials.password
  port     = local.db_credentials.port
  
  # 네트워크 설정
  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [aws_security_group.mysql.id]
  availability_zone      = var.availability_zone_a
  publicly_accessible    = false
  multi_az               = var.multi_az
  
  # 백업 설정 (최소화)
  backup_retention_period = var.backup_retention_period
  backup_window           = null  # 백업 비활성화시 불필요
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection
  
  # 모니터링 비활성화
  monitoring_interval = 0
  
  # 불필요한 옵션 비활성화
  performance_insights_enabled = false
  auto_minor_version_upgrade  = false
  
  # 암호화 비활성화 (비용 절감)
  storage_encrypted = false
  
  # 유지 관리 기간 설정 (트래픽 낮은 시간대)
  maintenance_window = "Sun:03:00-Sun:04:00"
  
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-mysql"
  })
}