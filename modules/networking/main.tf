#---------------------------------------
# VPC 리소스
#---------------------------------------
# VPC 생성
resource "aws_vpc" "vpc_tier3" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  
  tags = {
    Name = "VPC_${var.project_name}"
  }
}

# 인터넷 게이트웨이 생성
resource "aws_internet_gateway" "igw_tier3" {
  vpc_id = aws_vpc.vpc_tier3.id
  
  tags = {
    Name = "IGW_${var.project_name}"
  }
}

#---------------------------------------
# 서브넷 리소스
#---------------------------------------
# 퍼블릭 서브넷 생성 (A 가용 영역)
resource "aws_subnet" "subnet_public_azone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = var.public_subnet_cidrs["Azone"]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "SUBNET_public_Azone"
    Tier = "Public"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

# 퍼블릭 서브넷 생성 (C 가용 영역)
resource "aws_subnet" "subnet_public_czone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = var.public_subnet_cidrs["Czone"]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "SUBNET_public_Czone"
    Tier = "Public"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

# 프라이빗 서브넷 생성 (A 가용 영역) - 기존 NAT 서브넷
resource "aws_subnet" "subnet_private_azone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = var.nat_subnet_cidrs["Azone"]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "SUBNET_private_Azone"
    Tier = "Private"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# 프라이빗 서브넷 생성 (C 가용 영역) - 기존 NAT 서브넷
resource "aws_subnet" "subnet_private_czone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = var.nat_subnet_cidrs["Czone"]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "SUBNET_private_Czone"
    Tier = "Private"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# 데이터베이스 서브넷 생성 (A 가용 영역) - 기존 프라이빗 서브넷
resource "aws_subnet" "subnet_database_azone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = var.private_subnet_cidrs["Azone"]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "SUBNET_database_Azone"
    Tier = "Database"
  }
}

# 데이터베이스 서브넷 생성 (C 가용 영역) - 기존 프라이빗 서브넷
resource "aws_subnet" "subnet_database_czone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = var.private_subnet_cidrs["Czone"]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "SUBNET_database_Czone"
    Tier = "Database"
  }
}

#======================================================
# NAT 게이트웨이 관련 리소스
#======================================================

#---------------------------------------
# Elastic IP 할당 - NAT 게이트웨이용
#---------------------------------------
# 이전 코드 (여러 EIP 사용)
# resource "aws_eip" "nat_eip_a" {
#   domain = "vpc"
#   tags = {
#     Name = "${var.project_name}-nat-eip-a"
#   }
# }
# 
# resource "aws_eip" "nat_eip_c" {
#   domain = "vpc"
#   tags = {
#     Name = "${var.project_name}-nat-eip-c"
#   }
# }

# 수정된 코드 (단일 EIP 사용)
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

#---------------------------------------
# NAT 게이트웨이 생성
#---------------------------------------
# 이전 코드 (여러 NAT 게이트웨이 사용)
# resource "aws_nat_gateway" "nat_gateway_a" {
#   allocation_id = aws_eip.nat_eip_a.id
#   subnet_id     = aws_subnet.subnet_public_azone.id
# 
#   tags = {
#     Name = "${var.project_name}-nat-gw-a"
#   }
# 
#   depends_on = [aws_internet_gateway.igw_tier3]
# }
# 
# resource "aws_nat_gateway" "nat_gateway_c" {
#   allocation_id = aws_eip.nat_eip_c.id
#   subnet_id     = aws_subnet.subnet_public_czone.id
# 
#   tags = {
#     Name = "${var.project_name}-nat-gw-c"
#   }
# 
#   depends_on = [aws_internet_gateway.igw_tier3]
# }

# 수정된 코드 (단일 NAT 게이트웨이 사용)
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet_public_azone.id  # A 가용 영역의 퍼블릭 서브넷에만 배치

  tags = {
    Name = "${var.project_name}-nat-gw"
  }

  depends_on = [aws_internet_gateway.igw_tier3]
}

#---------------------------------------
# 라우팅 테이블 생성
#---------------------------------------

# 1. 퍼블릭 서브넷용 라우팅 테이블 - 인터넷 게이트웨이로 라우팅
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc_tier3.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_tier3.id
  }

  tags = {
    Name = "${var.project_name}-rt-public"
  }
}

# 2. NAT 서브넷용 라우팅 테이블 - NAT 게이트웨이로 라우팅
resource "aws_route_table" "rt_nat" {
  vpc_id = aws_vpc.vpc_tier3.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.project_name}-rt-nat"
  }
}

# 3. 프라이빗 서브넷용 라우팅 테이블 - 외부 통신 없음
resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.vpc_tier3.id

  # 외부 통신이 필요없는 경우 기본 라우팅만 유지
  # 필요시 다음과 같이 NAT 게이트웨이 경로 추가 가능
  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.nat_gateway.id
  # }

  tags = {
    Name = "${var.project_name}-rt-private"
  }
}

#---------------------------------------
# 라우팅 테이블 연결
#---------------------------------------

# 퍼블릭 서브넷에 퍼블릭 라우팅 테이블 연결
resource "aws_route_table_association" "rta_public_a" {
  subnet_id      = aws_subnet.subnet_public_azone.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "rta_public_c" {
  subnet_id      = aws_subnet.subnet_public_czone.id
  route_table_id = aws_route_table.rt_public.id
}

# 프라이빗 서브넷에 NAT 라우팅 테이블 연결 (기존 NAT 서브넷)
resource "aws_route_table_association" "rta_private_a" {
  subnet_id      = aws_subnet.subnet_private_azone.id
  route_table_id = aws_route_table.rt_nat.id
}

resource "aws_route_table_association" "rta_private_c" {
  subnet_id      = aws_subnet.subnet_private_czone.id
  route_table_id = aws_route_table.rt_nat.id
}

# 데이터베이스 서브넷에 프라이빗 라우팅 테이블 연결 (기존 프라이빗 서브넷)
resource "aws_route_table_association" "rta_database_a" {
  subnet_id      = aws_subnet.subnet_database_azone.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table_association" "rta_database_c" {
  subnet_id      = aws_subnet.subnet_database_czone.id
  route_table_id = aws_route_table.rt_private.id
}

#---------------------------------------
# 데이터베이스 서브넷 그룹
#---------------------------------------
# 데이터베이스 서브넷 그룹 생성 (RDS 등을 위한 설정)
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "db-subnet-group-${var.project_name}"
  description = "Database subnet group for ${var.project_name}"
  subnet_ids  = [
    aws_subnet.subnet_database_azone.id,
    aws_subnet.subnet_database_czone.id
  ]
  
  tags = {
    Name = "DB_SUBNET_GROUP_${var.project_name}"
  }
}