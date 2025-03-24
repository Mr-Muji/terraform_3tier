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
    Environment = var.environment
  }
}

# 인터넷 게이트웨이 생성
resource "aws_internet_gateway" "igw_tier3" {
  vpc_id = aws_vpc.vpc_tier3.id
  
  tags = {
    Name = "IGW_${var.project_name}"
    Environment = var.environment
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
    Name = "${var.project_name}-public-subnet-a"
    Environment = var.environment
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
    Name = "${var.project_name}-public-subnet-c"
    Environment = var.environment
    Tier = "Public"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

# 프라이빗 서브넷 생성 (A 가용 영역) - 애플리케이션용
resource "aws_subnet" "subnet_private_azone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = var.private_subnet_cidrs["Azone"]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-subnet-a"
    Environment = var.environment
    Tier = "Private"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# 프라이빗 서브넷 생성 (C 가용 영역) - 애플리케이션용
resource "aws_subnet" "subnet_private_czone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = var.private_subnet_cidrs["Czone"]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-subnet-c"
    Environment = var.environment
    Tier = "Private"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# 데이터베이스 서브넷 생성 (A 가용 영역)
resource "aws_subnet" "subnet_database_azone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = var.database_subnet_cidrs["Azone"]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-database-subnet-a"
    Environment = var.environment
    Tier = "Database"
  }
}

# 데이터베이스 서브넷 생성 (C 가용 영역)
resource "aws_subnet" "subnet_database_czone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = var.database_subnet_cidrs["Czone"]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-database-subnet-c"
    Environment = var.environment
    Tier = "Database"
  }
}

#======================================================
# NAT 게이트웨이 관련 리소스
#======================================================

#---------------------------------------
# 탄력적 IP 할당 - NAT 게이트웨이용
#---------------------------------------
# 탄력적 IP 생성 (A 가용 영역만 사용)
resource "aws_eip" "eip_nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-eip-nat"
    Environment = var.environment
  }
}

#---------------------------------------
# NAT 게이트웨이 생성
#---------------------------------------
# NAT 게이트웨이 생성 (A 가용 영역에만 생성)
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id     = aws_subnet.subnet_public_azone.id
  
  tags = {
    Name = "${var.project_name}-nat-gw"
    Environment = var.environment
  }
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
    Environment = var.environment
  }
}

# 2. 프라이빗 서브넷용 라우팅 테이블 - NAT 게이트웨이로 라우팅 (A존과 C존 모두 동일한 NAT 게이트웨이 사용)
resource "aws_route_table" "rt_private_azone" {
  vpc_id = aws_vpc.vpc_tier3.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.project_name}-rt-private-a"
    Environment = var.environment
  }
}

resource "aws_route_table" "rt_private_czone" {
  vpc_id = aws_vpc.vpc_tier3.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.project_name}-rt-private-c"
    Environment = var.environment
  }
}

# 3. 데이터베이스 서브넷용 라우팅 테이블 - NAT 게이트웨이로 라우팅 (필요한 경우)
resource "aws_route_table" "rt_database_azone" {
  vpc_id = aws_vpc.vpc_tier3.id

  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.nat_gw.id
  # }

  tags = {
    Name = "${var.project_name}-rt-database-a"
    Environment = var.environment
  }
}

resource "aws_route_table" "rt_database_czone" {
  vpc_id = aws_vpc.vpc_tier3.id

  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.nat_gw.id
  # }

  tags = {
    Name = "${var.project_name}-rt-database-c"
    Environment = var.environment
  }
}

#---------------------------------------
# 라우팅 테이블 연결
#---------------------------------------

# 퍼블릭 서브넷에 퍼블릭 라우팅 테이블 연결
resource "aws_route_table_association" "rta_public_azone" {
  subnet_id      = aws_subnet.subnet_public_azone.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "rta_public_czone" {
  subnet_id      = aws_subnet.subnet_public_czone.id
  route_table_id = aws_route_table.rt_public.id
}

# 프라이빗 서브넷에 NAT 라우팅 테이블 연결 (기존 NAT 서브넷)
resource "aws_route_table_association" "rta_private_azone" {
  subnet_id      = aws_subnet.subnet_private_azone.id
  route_table_id = aws_route_table.rt_private_azone.id
}

resource "aws_route_table_association" "rta_private_czone" {
  subnet_id      = aws_subnet.subnet_private_czone.id
  route_table_id = aws_route_table.rt_private_czone.id
}

# 데이터베이스 서브넷에 프라이빗 라우팅 테이블 연결 (기존 프라이빗 서브넷)
resource "aws_route_table_association" "rta_database_azone" {
  subnet_id      = aws_subnet.subnet_database_azone.id
  route_table_id = aws_route_table.rt_database_azone.id
}

resource "aws_route_table_association" "rta_database_czone" {
  subnet_id      = aws_subnet.subnet_database_czone.id
  route_table_id = aws_route_table.rt_database_czone.id
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