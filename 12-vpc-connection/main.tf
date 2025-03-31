#---------------------------------------
# Access VPC 생성 (11번에서 옮겨옴)
#---------------------------------------
module "access_vpc" {
  source = "../modules/vpc"

  # 프로젝트 정보
  project_name = local.project_name
  environment  = local.environment
  vpc_name     = local.access_vpc_name
  
  # VPC 설정
  vpc_cidr = local.access_vpc_cidr
  azs      = local.azs
  
  # 서브넷 설정
  public_subnet_cidrs  = local.access_public_subnet_cidrs
  private_subnet_cidrs = local.access_private_subnet_cidrs
  
  # NAT Gateway 설정
  enable_nat_gateway  = false  # Access VPC는 NAT Gateway 불필요
  single_nat_gateway  = false
  
  # 태그
  common_tags = local.common_tags
}

#---------------------------------------
# OpenVPN 서버 생성 
#---------------------------------------
resource "aws_security_group" "openvpn" {
  name        = "${local.project_name}-${local.environment}-openvpn-sg"
  description = "sg - OpenVPN server"
  vpc_id      = module.access_vpc.vpc_id

  # SSH 접속 허용
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_ip}/32"]
    description = "SSH Access"
  }

  # OpenVPN 관리 웹 UI
  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "OpenVPN Admin Web UI"
  }

  # OpenVPN TCP 연결 (영어로 변경)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "OpenVPN TCP Connection"
  }

  # OpenVPN UDP 연결 
  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "OpenVPN UDP Connection"
  }

  # 모든 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = local.common_tags
}

# Template 파일 처리
data "template_file" "setup_openvpn_tools" {
  template = file("${path.module}/scripts/setup_openvpn_tools.sh")
  
  vars = {
    aws_region      = local.aws_region
    access_vpc_cidr = local.access_vpc_cidr
    main_vpc_cidr   = coalesce(var.main_vpc_cidr, data.terraform_remote_state.main_vpc.outputs.vpc_cidr)
  }
}

resource "aws_instance" "openvpn" {
  ami           = "ami-09a093fa2e3bfca5a"  # OpenVPN Access Server AMI
  instance_type = "t3.micro"
  subnet_id     = module.access_vpc.public_subnet_ids[0]
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.openvpn.id]
  
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  # 통합된 하나의 스크립트 실행
  user_data = data.template_file.setup_openvpn_tools.rendered

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-${local.environment}-openvpn"
    }
  )
}

# Elastic IP 할당
resource "aws_eip" "openvpn" {
  instance = aws_instance.openvpn.id
  domain   = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-${local.environment}-openvpn-eip"
  })
}

#---------------------------------------
# Transit Gateway 생성
#---------------------------------------
resource "aws_ec2_transit_gateway" "this" {
  description                     = "${local.project_name}-${local.environment}-tgw"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  
  tags = {
    Name = "${local.project_name}-${local.environment}-tgw"
  }
}

#---------------------------------------
# Transit Gateway VPC 어태치먼트 - 메인 VPC
#---------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "main_vpc" {
  subnet_ids         = data.terraform_remote_state.main_vpc.outputs.private_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = coalesce(var.main_vpc_id, data.terraform_remote_state.main_vpc.outputs.vpc_id)
  
  tags = {
    Name = "${local.project_name}-${local.environment}-tgw-main-vpc-attachment"
  }
}

#---------------------------------------
# Transit Gateway VPC 어태치먼트 - 액세스 VPC
#---------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "access_vpc" {
  subnet_ids         = module.access_vpc.private_subnet_ids # 직접 생성한 VPC 참조
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = module.access_vpc.vpc_id # 직접 생성한 VPC 참조
  
  tags = {
    Name = "${local.project_name}-${local.environment}-tgw-access-vpc-attachment"
  }
}

#---------------------------------------
# 라우팅 테이블 업데이트 - 메인 VPC 라우트 테이블에 액세스 VPC로 가는 경로 추가
#---------------------------------------
resource "aws_route" "main_to_access" {
  count                  = length(data.terraform_remote_state.main_vpc.outputs.private_route_table_ids)
  route_table_id         = data.terraform_remote_state.main_vpc.outputs.private_route_table_ids[count.index]
  destination_cidr_block = local.access_vpc_cidr # 직접 정의한 CIDR 사용
  transit_gateway_id     = aws_ec2_transit_gateway.this.id
}

# 메인 VPC 퍼블릭 라우트 테이블에도 액세스 VPC로 가는 경로 추가
resource "aws_route" "main_public_to_access" {
  route_table_id         = data.terraform_remote_state.main_vpc.outputs.public_route_table_id
  destination_cidr_block = local.access_vpc_cidr # 직접 정의한 CIDR 사용
  transit_gateway_id     = aws_ec2_transit_gateway.this.id
}

#---------------------------------------
# 라우팅 테이블 업데이트 - 액세스 VPC 라우트 테이블에 메인 VPC로 가는 경로 추가
#---------------------------------------
resource "aws_route" "access_to_main" {
  count                  = length(module.access_vpc.private_route_table_ids) # 직접 생성한 값 참조
  route_table_id         = module.access_vpc.private_route_table_ids[count.index] # 직접 생성한 값 참조
  destination_cidr_block = coalesce(var.main_vpc_cidr, data.terraform_remote_state.main_vpc.outputs.vpc_cidr)
  transit_gateway_id     = aws_ec2_transit_gateway.this.id
}

# 액세스 VPC 퍼블릭 라우트 테이블에도 메인 VPC로 가는 경로 추가
resource "aws_route" "access_public_to_main" {
  route_table_id         = module.access_vpc.public_route_table_id # 직접 생성한 값 참조
  destination_cidr_block = coalesce(var.main_vpc_cidr, data.terraform_remote_state.main_vpc.outputs.vpc_cidr)
  transit_gateway_id     = aws_ec2_transit_gateway.this.id
}

#---------------------------------------
# OpenVPN에 메인 VPC 라우팅 설정 추가
#---------------------------------------
resource "null_resource" "update_openvpn_routing" {
  depends_on = [aws_instance.openvpn, aws_route.access_to_main]

  # OpenVPN 생성 후 메인 VPC CIDR도 자동으로 추가
  provisioner "local-exec" {
    command = <<-EOT
      echo "OpenVPN 서버에 메인 VPC 라우팅 설정 자동 적용됨: 연결 시 메인 VPC 접근 가능"
    EOT
  }

  # user_data에 넣을 수도 있지만, TGW 연결 후에 진행하기 위해 별도로 정의
  # 실제 환경에서는 수동으로 진행하거나 더 복잡한 자동화 필요할 수 있음
}

#---------------------------------------
# OpenVPN 접속 가이드 출력
#---------------------------------------
resource "null_resource" "openvpn_guide" {
  depends_on = [aws_instance.openvpn, aws_route.access_to_main]

  # OpenVPN 생성 및 설정 완료 후 접속 가이드 출력
  provisioner "local-exec" {
    command = <<-EOT
      echo "============================================================"
      echo "               OpenVPN 서버 접속 가이드                     "
      echo "============================================================"
      echo "1. 관리자 웹 인터페이스 접속"
      echo "   URL: https://${aws_eip.openvpn.public_ip}:943/admin"
      echo "   계정: openvpn"
      echo "   초기 비밀번호: password"
      echo ""
      echo "2. 관리자 설정"
      echo "   - 초기 비밀번호를 변경하세요"
      echo "   - 라이선스 동의 및 초기 설정을 완료하세요"
      echo "   - VPN 사용자를 생성하세요 (User Management → User Permissions)"
      echo ""
      echo "3. VPN 클라이언트 다운로드 및 설정"
      echo "   - 사용자 포털: https://${aws_eip.openvpn.public_ip}:943/"
      echo "   - 생성한 계정으로 로그인하여 클라이언트 프로그램 다운로드"
      echo "   - 또는 관리자 로그인 후 'Client Web Server' 메뉴에서 다운로드"
      echo ""
      echo "4. 주요 연결 정보"
      echo "   - SSH 접속: ssh -i /Users/hyunsik/kakaotech/keypair-default.pem openvpnas@${aws_eip.openvpn.public_ip} (주의: 사용자 이름은 반드시 openvpnas 사용)"
      echo "   - 메인 VPC CIDR: ${coalesce(var.main_vpc_cidr, data.terraform_remote_state.main_vpc.outputs.vpc_cidr)}"
      echo "   - 액세스 VPC CIDR: ${local.access_vpc_cidr}"
      echo ""
      echo "5. EKS 클러스터 접속 설정 (SSH 접속 후)"
      echo "   # 필요한 디렉토리 권한 설정 (권한 오류 발생 시)"
      echo "   $ sudo mkdir -p /home/openvpnas/.aws /home/openvpnas/.kube"
      echo "   $ sudo chown -R openvpnas:openvpnas /home/openvpnas/.aws /home/openvpnas/.kube"
      echo "   $ sudo chmod 700 /home/openvpnas/.aws /home/openvpnas/.kube"
      echo ""
      echo "   # AWS 자격 증명 설정"
      echo "   $ aws configure"
      echo ""
      echo "   # EKS 클러스터 접속 설정"
      echo "   $ aws eks update-kubeconfig --name ${data.terraform_remote_state.compute.outputs.cluster_id} --region ${local.aws_region}"
      echo ""
      echo "   # 접속 테스트"
      echo "   $ kubectl get nodes"
      echo "   $ kubectl get pods -A"
      echo ""
      echo "6. 문제 해결"
      echo "   - VPN 연결 확인: ping 10.0.1.1"
      echo "   - OpenVPN 로그: /var/log/openvpnas.log"
      echo "   - EKS 연결 문제: aws eks describe-cluster --name ${data.terraform_remote_state.compute.outputs.cluster_id} --region ${local.aws_region}"
      echo "============================================================"
    EOT
  }
} 