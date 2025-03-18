# AWS 프로바이더 설정 - Seoul 리전 지정
provider "aws" {
  region = "ap-northeast-2"  # 서울 리전을 사용합니다
}

# 테라폼 설정 - 필요한 프로바이더 및 버전 지정
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # AWS 프로바이더의 소스
      version = "~> 5.0"        # AWS 프로바이더 버전
    }
  }
  required_version = ">= 1.2.0"  # 테라폼 최소 버전
}

# VPC 생성 - 모든 리소스가 포함될 네트워크 공간
resource "aws_vpc" "vpc_tier3" {
  cidr_block           = "10.0.0.0/16"        # VPC의 IP 주소 범위
  enable_dns_support   = true                 # DNS 이름 해석 활성화
  enable_dns_hostnames = true                 # DNS 호스트 이름 활성화
  
  tags = {
    Name = "VPC_tier3"
  }
}

# 인터넷 게이트웨이 생성 - VPC와 인터넷 연결
resource "aws_internet_gateway" "igw_tier3" {
  vpc_id = aws_vpc.vpc_tier3.id               # VPC와 연결
  
  tags = {
    Name = "IGW_tier3"
  }
}

# 퍼블릭 서브넷 생성 (A 가용 영역) - 웹 서버 등 인터넷 연결 필요 리소스용
resource "aws_subnet" "subnet_public_azone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = "10.0.1.0/24"     # 퍼블릭 A 영역의 IP 주소 범위
  availability_zone       = "ap-northeast-2a" # 서울 리전의 A 가용 영역
  map_public_ip_on_launch = true              # 리소스 생성 시 퍼블릭 IP 자동 할당

  tags = {
    Name = "SUBNET_public_Azone"
    Tier = "Public"
  }
}

# 퍼블릭 서브넷 생성 (C 가용 영역) - 고가용성을 위한 두번째 영역
resource "aws_subnet" "subnet_public_czone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = "10.0.2.0/24"     # 퍼블릭 C 영역의 IP 주소 범위
  availability_zone       = "ap-northeast-2c" # 서울 리전의 C 가용 영역
  map_public_ip_on_launch = true              # 리소스 생성 시 퍼블릭 IP 자동 할당

  tags = {
    Name = "SUBNET_public_Czone"
    Tier = "Public"
  }
}

# NAT 서브넷 생성 (A 가용 영역) - 애플리케이션 계층용
resource "aws_subnet" "subnet_nat_azone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = "10.0.10.0/24"    # NAT A 영역의 IP 주소 범위
  availability_zone       = "ap-northeast-2a" # 서울 리전의 A 가용 영역
  map_public_ip_on_launch = false             # 퍼블릭 IP 자동 할당 비활성화

  tags = {
    Name = "SUBNET_nat_Azone"
    Tier = "NAT"
  }
}

# NAT 서브넷 생성 (C 가용 영역) - 애플리케이션 계층의 고가용성을 위한 두번째 영역
resource "aws_subnet" "subnet_nat_czone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = "10.0.20.0/24"    # NAT C 영역의 IP 주소 범위
  availability_zone       = "ap-northeast-2c" # 서울 리전의 C 가용 영역
  map_public_ip_on_launch = false             # 퍼블릭 IP 자동 할당 비활성화

  tags = {
    Name = "SUBNET_nat_Czone"
    Tier = "NAT"
  }
}

# 프라이빗 서브넷 생성 (A 가용 영역) - 데이터베이스 등 비공개 리소스용
resource "aws_subnet" "subnet_private_azone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = "10.0.100.0/24"   # 프라이빗 A 영역의 IP 주소 범위
  availability_zone       = "ap-northeast-2a" # 서울 리전의 A 가용 영역
  map_public_ip_on_launch = false             # 퍼블릭 IP 자동 할당 비활성화

  tags = {
    Name = "SUBNET_private_Azone"
    Tier = "Private"
  }
}

# 프라이빗 서브넷 생성 (C 가용 영역) - 데이터 계층의 고가용성을 위한 두번째 영역
resource "aws_subnet" "subnet_private_czone" {
  vpc_id                  = aws_vpc.vpc_tier3.id
  cidr_block              = "10.0.200.0/24"   # 프라이빗 C 영역의 IP 주소 범위
  availability_zone       = "ap-northeast-2c" # 서울 리전의 C 가용 영역
  map_public_ip_on_launch = false             # 퍼블릭 IP 자동 할당 비활성화

  tags = {
    Name = "SUBNET_private_Czone"
    Tier = "Private"
  }
}

# 퍼블릭 라우팅 테이블 생성 - 인터넷 게이트웨이로 트래픽 라우팅
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc_tier3.id

  # 인터넷으로 가는 모든 트래픽을 인터넷 게이트웨이로 보냄
  route {
    cidr_block = "0.0.0.0/0"                  # 모든 트래픽
    gateway_id = aws_internet_gateway.igw_tier3.id # 인터넷 게이트웨이로 라우팅
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

# NAT 게이트웨이를 위한 탄력적 IP 생성 (A 가용 영역) - 고정 퍼블릭 IP
resource "aws_eip" "eip_nat_azone" {
  domain = "vpc"                              # VPC 내에서 사용
  
  tags = {
    Name = "EIP_nat_Azone"
  }
}

# NAT 게이트웨이를 위한 탄력적 IP 생성 (C 가용 영역) - 고정 퍼블릭 IP
resource "aws_eip" "eip_nat_czone" {
  domain = "vpc"                              # VPC 내에서 사용
  
  tags = {
    Name = "EIP_nat_Czone"
  }
}

# NAT 게이트웨이 생성 (A 가용 영역) - 프라이빗 서브넷에서 외부 통신 허용
resource "aws_nat_gateway" "natgw_azone" {
  allocation_id = aws_eip.eip_nat_azone.id    # 탄력적 IP 연결
  subnet_id     = aws_subnet.subnet_public_azone.id # 퍼블릭 서브넷에 위치
  
  tags = {
    Name = "NATGW_Azone"
  }
  
  # 인터넷 게이트웨이가 완전히 생성된 후에 NAT 게이트웨이 생성
  depends_on = [aws_internet_gateway.igw_tier3]
}

# NAT 게이트웨이 생성 (C 가용 영역) - 고가용성을 위한 두번째 NAT 게이트웨이
resource "aws_nat_gateway" "natgw_czone" {
  allocation_id = aws_eip.eip_nat_czone.id    # 탄력적 IP 연결
  subnet_id     = aws_subnet.subnet_public_czone.id # 퍼블릭 서브넷에 위치
  
  tags = {
    Name = "NATGW_Czone"
  }
  
  depends_on = [aws_internet_gateway.igw_tier3]
}

# NAT 서브넷 라우팅 테이블 생성 (A 가용 영역) - NAT 게이트웨이로 트래픽 라우팅
resource "aws_route_table" "rt_nat_azone" {
  vpc_id = aws_vpc.vpc_tier3.id

  # 인터넷으로 가는 모든 트래픽을 NAT 게이트웨이로 보냄
  route {
    cidr_block     = "0.0.0.0/0"              # 모든 트래픽
    nat_gateway_id = aws_nat_gateway.natgw_azone.id # A 영역 NAT 게이트웨이로 라우팅
  }

  tags = {
    Name = "RT_nat_Azone"
  }
}

# NAT 서브넷 라우팅 테이블 생성 (C 가용 영역) - NAT 게이트웨이로 트래픽 라우팅
resource "aws_route_table" "rt_nat_czone" {
  vpc_id = aws_vpc.vpc_tier3.id

  route {
    cidr_block     = "0.0.0.0/0"              # 모든 트래픽
    nat_gateway_id = aws_nat_gateway.natgw_czone.id # C 영역 NAT 게이트웨이로 라우팅
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

# 프라이빗 서브넷 라우팅 테이블 생성 - VPC 내부 통신만 허용
resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.vpc_tier3.id

  # 기본적으로 로컬 라우팅만 사용 (NAT 게이트웨이로 라우팅하지 않음)
  # 명시적인 로컬 라우팅은 설정하지 않아도 됨 (AWS에서 자동으로 추가)
  
  tags = {
    Name = "RT_private"
  }
}

# 프라이빗 서브넷과 프라이빗 라우팅 테이블 연결 (A 가용 영역)
resource "aws_route_table_association" "rta_private_azone" {
  subnet_id      = aws_subnet.subnet_private_azone.id
  route_table_id = aws_route_table.rt_private.id
}

# 프라이빗 서브넷과 프라이빗 라우팅 테이블 연결 (C 가용 영역)
resource "aws_route_table_association" "rta_private_czone" {
  subnet_id      = aws_subnet.subnet_private_czone.id
  route_table_id = aws_route_table.rt_private.id
}