# AWS 프로바이더 설정
provider "aws" {
  region = "ap-northeast-2"  # 서울 리전을 사용합니다
}

# 테라폼 설정
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # AWS 프로바이더의 소스
      version = "~> 5.0"        # AWS 프로바이더 버전
    }
  }
  required_version = ">= 1.2.0"  # 테라폼 최소 버전
}

# VPC 생성
resource "aws_vpc" "vpc_tier3" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "VPC_tier3"
  }
}

# 인터넷 게이트웨이 생성
resource "aws_internet_gateway" "igw_tier3" {
  vpc_id = aws_vpc.vpc_tier3.id
  
  tags = {
    Name = "IGW_tier3"
  }
}

# 퍼블릭 서브넷 생성 (A 가용 영역)
resource "aws_subnet" "subnet_public_azone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "SUBNET_public_Azone"
    Tier = "Public"
  }
}

# 퍼블릭 서브넷 생성 (C 가용 영역)
resource "aws_subnet" "subnet_public_czone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "SUBNET_public_Czone"
    Tier = "Public"
  }
}

# NAT 서브넷 생성 (A 가용 영역)
resource "aws_subnet" "subnet_nat_azone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "SUBNET_nat_Azone"
    Tier = "NAT"
  }
}

# NAT 서브넷 생성 (C 가용 영역)
resource "aws_subnet" "subnet_nat_czone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "SUBNET_nat_Czone"
    Tier = "NAT"
  }
}

# 프라이빗 서브넷 생성 (A 가용 영역)
resource "aws_subnet" "subnet_private_azone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "SUBNET_private_Azone"
    Tier = "Private"
  }
}

# 프라이빗 서브넷 생성 (C 가용 영역)
resource "aws_subnet" "subnet_private_czone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "SUBNET_private_Czone"
    Tier = "Private"
  }
}

# 퍼블릭 라우팅 테이블 생성
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc_tier3.id

  # 인터넷으로 가는 모든 트래픽을 인터넷 게이트웨이로 보냄
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_tier3.id
  }

  tags = {
    Name = "RT_public"
  }
}

# 퍼블릭 서브넷과 퍼블릭 라우팅 테이블 연결 (A 가용 영역)
resource "aws_route_table_association" "rta_public_azone" {
  subnet_id      = aws_subnet.subnet_public_azone.id
  route_table_id = aws_route_table.rt_public.id
}

# 퍼블릭 서브넷과 퍼블릭 라우팅 테이블 연결 (C 가용 영역)
resource "aws_route_table_association" "rta_public_czone" {
  subnet_id      = aws_subnet.subnet_public_czone.id
  route_table_id = aws_route_table.rt_public.id
}

# NAT 게이트웨이를 위한 탄력적 IP 생성 (A 가용 영역)
resource "aws_eip" "eip_nat_azone" {
  domain = "vpc"
  
  tags = {
    Name = "EIP_nat_Azone"
  }
}

# NAT 게이트웨이를 위한 탄력적 IP 생성 (C 가용 영역)
resource "aws_eip" "eip_nat_czone" {
  domain = "vpc"
  
  tags = {
    Name = "EIP_nat_Czone"
  }
}

# NAT 게이트웨이 생성 (A 가용 영역)
resource "aws_nat_gateway" "natgw_azone" {
  allocation_id = aws_eip.eip_nat_azone.id
  subnet_id     = aws_subnet.subnet_public_azone.id
  
  tags = {
    Name = "NATGW_Azone"
  }
  
  # 인터넷 게이트웨이가 완전히 생성된 후에 NAT 게이트웨이 생성
  depends_on = [aws_internet_gateway.igw_tier3]
}

# NAT 게이트웨이 생성 (C 가용 영역)
resource "aws_nat_gateway" "natgw_czone" {
  allocation_id = aws_eip.eip_nat_czone.id
  subnet_id     = aws_subnet.subnet_public_czone.id
  
  tags = {
    Name = "NATGW_Czone"
  }
  
  depends_on = [aws_internet_gateway.igw_tier3]
}

# NAT 서브넷 라우팅 테이블 생성 (A 가용 영역)
resource "aws_route_table" "rt_nat_azone" {
  vpc_id = aws_vpc.vpc_tier3.id

  # 인터넷으로 가는 모든 트래픽을 NAT 게이트웨이로 보냄
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw_azone.id
  }

  tags = {
    Name = "RT_nat_Azone"
  }
}

# NAT 서브넷 라우팅 테이블 생성 (C 가용 영역)
resource "aws_route_table" "rt_nat_czone" {
  vpc_id = aws_vpc.vpc_tier3.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw_czone.id
  }

  tags = {
    Name = "RT_nat_Czone"
  }
}

# NAT 서브넷과 NAT 라우팅 테이블 연결 (A 가용 영역)
resource "aws_route_table_association" "rta_nat_azone" {
  subnet_id      = aws_subnet.subnet_nat_azone.id
  route_table_id = aws_route_table.rt_nat_azone.id
}

# NAT 서브넷과 NAT 라우팅 테이블 연결 (C 가용 영역)
resource "aws_route_table_association" "rta_nat_czone" {
  subnet_id      = aws_subnet.subnet_nat_czone.id
  route_table_id = aws_route_table.rt_nat_czone.id
}

# 프라이빗 서브넷 라우팅 테이블 생성 (A 가용 영역)
resource "aws_route_table" "rt_private_azone" {
  vpc_id = aws_vpc.vpc_tier3.id

  # 인터넷으로 가는 모든 트래픽을 NAT 게이트웨이로 보냄
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw_azone.id
  }

  tags = {
    Name = "RT_private_Azone"
  }
}

# 프라이빗 서브넷 라우팅 테이블 생성 (C 가용 영역)
resource "aws_route_table" "rt_private_czone" {
  vpc_id = aws_vpc.vpc_tier3.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw_czone.id
  }

  tags = {
    Name = "RT_private_Czone"
  }
}

# 프라이빗 서브넷과 프라이빗 라우팅 테이블 연결 (A 가용 영역)
resource "aws_route_table_association" "rta_private_azone" {
  subnet_id      = aws_subnet.subnet_private_azone.id
  route_table_id = aws_route_table.rt_private_azone.id
}

# 프라이빗 서브넷과 프라이빗 라우팅 테이블 연결 (C 가용 영역)
resource "aws_route_table_association" "rta_private_czone" {
  subnet_id      = aws_subnet.subnet_private_czone.id
  route_table_id = aws_route_table.rt_private_czone.id
}