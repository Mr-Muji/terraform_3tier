#---------------------------------------
# 액세스 VPC 출력값 (11번에서 옮겨옴)
#---------------------------------------
output "access_vpc_id" {
  description = "Access VPC ID"
  value       = module.access_vpc.vpc_id
}

output "access_vpc_cidr" {
  description = "Access VPC CIDR 블록"
  value       = module.access_vpc.vpc_cidr
}

output "access_public_subnet_ids" {
  description = "액세스 VPC 퍼블릭 서브넷 ID 목록"
  value       = module.access_vpc.public_subnet_ids
}

output "access_private_subnet_ids" {
  description = "액세스 VPC 프라이빗 서브넷 ID 목록"
  value       = module.access_vpc.private_subnet_ids
}

output "access_public_route_table_id" {
  description = "액세스 VPC 퍼블릭 라우트 테이블 ID"
  value       = module.access_vpc.public_route_table_id
}

output "access_private_route_table_ids" {
  description = "액세스 VPC 프라이빗 라우트 테이블 ID 목록"
  value       = module.access_vpc.private_route_table_ids
}

#---------------------------------------
# OpenVPN 출력값
#---------------------------------------
output "openvpn_public_ip" {
  description = "OpenVPN 서버 퍼블릭 IP"
  value       = aws_eip.openvpn.public_ip
}

output "openvpn_admin_url" {
  description = "OpenVPN 관리자 웹 인터페이스 URL"
  value       = "https://${aws_eip.openvpn.public_ip}:943/admin"
}

output "openvpn_user_portal" {
  description = "OpenVPN 사용자 포털 URL"
  value       = "https://${aws_eip.openvpn.public_ip}:943/"
}

output "openvpn_ssh_command" {
  description = "OpenVPN 서버 SSH 접속 명령어"
  value       = "ssh -i /path/to/${var.key_name}.pem openvpnas@${aws_eip.openvpn.public_ip}"
}

output "openvpn_connection_guide" {
  description = "OpenVPN 설정 및 접속 가이드"
  value       = <<-EOT
    ==========[ OpenVPN 서버 접속 가이드 ]==========
    
    1. 관리자 웹 인터페이스 접속
       URL: https://${aws_eip.openvpn.public_ip}:943/admin
       계정: openvpn
       초기 비밀번호: password
    
    2. 관리자 설정
       - 초기 비밀번호를 변경하세요 (중요: 보안을 위해 반드시 변경)
         $ ssh -i <키페어경로> openvpnas@${aws_eip.openvpn.public_ip}
         - password 로 비밀번호 변경
         $ sudo /usr/local/openvpn_as/scripts/sacli --user openvpn --new_pass password SetLocalPassword
       - 라이선스 동의 및 초기 설정을 완료하세요
       - VPN 사용자를 생성하세요 (User Management → User Permissions)
    
    3. VPN 클라이언트 다운로드 및 설정
       - 사용자 포털: https://${aws_eip.openvpn.public_ip}:943/
       - 생성한 계정으로 로그인하여 클라이언트 프로그램 다운로드
       - 또는 관리자 로그인 후 'Client Web Server' 메뉴에서 다운로드
    
    4. 주요 연결 정보
       - SSH 접속: ssh -i <키페어경로> openvpnas@${aws_eip.openvpn.public_ip}
       - 메인 VPC CIDR: ${coalesce(var.main_vpc_cidr, data.terraform_remote_state.main_vpc.outputs.vpc_cidr)}
       - 액세스 VPC CIDR: ${local.access_vpc_cidr}
    
    5. 문제 해결
       - 라우팅 설정 확인: VPN 연결 후 ping 10.0.1.1 테스트
       - OpenVPN 로그 확인: /var/log/openvpnas.log
       - OpenVPN 설정 명령: sudo /usr/local/openvpn_as/scripts/sacli --help
    
    =================================================
  EOT
}

# AWS CLI와 kubectl 사용 방법 가이드도 추가
output "openvpn_tools_guide" {
  description = "OpenVPN 서버에 설치된 도구 사용 가이드"
  value       = <<-EOT
    ==========[ AWS CLI 및 kubectl 사용 가이드 ]==========
    
    1. OpenVPN 서버에 SSH로 접속
       $ ssh -i /Users/hyunsik/kakaotech/${var.key_name}.pem ec2-user@${aws_eip.openvpn.public_ip}
    
    2. AWS CLI 설정
       $ aws configure
       AWS Access Key ID [None]: <액세스키입력>
       AWS Secret Access Key [None]: <시크릿키입력>
       Default region name [None]: ${local.aws_region}
       Default output format [None]: json
    
    3. EKS 클러스터 접속 설정
       $ aws eks update-kubeconfig --name ${data.terraform_remote_state.compute.outputs.cluster_id} --region ${local.aws_region}
    
    4. 클러스터 접속 확인
       $ kubectl get nodes
       $ kubectl get pods -A
       $ kubectl get namespaces
       $ kubectl get services -A
    
    5. 클러스터 모니터링
       $ kubectl top nodes
       $ kubectl top pods -A
    
    6. AWS 리소스 확인
       $ aws ec2 describe-instances --filters "Name=tag:Name,Values=*${local.project_name}*" --query "Reservations[].Instances[].{ID:InstanceId,Name:Tags[?Key=='Name']|[0].Value,State:State.Name,IP:PrivateIpAddress,Type:InstanceType}" --output table
       $ aws eks list-clusters
    
    7. AWS 자격 증명 확인
       $ aws sts get-caller-identity
    
    =================================================
  EOT
}

#---------------------------------------
# TGW 출력값
#---------------------------------------
output "transit_gateway_id" {
  description = "생성된 Transit Gateway ID"
  value       = aws_ec2_transit_gateway.this.id
}

output "main_vpc_attachment_id" {
  description = "메인 VPC Transit Gateway 어태치먼트 ID"
  value       = aws_ec2_transit_gateway_vpc_attachment.main_vpc.id
}

output "access_vpc_attachment_id" {
  description = "액세스 VPC Transit Gateway 어태치먼트 ID"
  value       = aws_ec2_transit_gateway_vpc_attachment.access_vpc.id
}

output "main_vpc_id" {
  description = "메인 VPC ID"
  value       = coalesce(var.main_vpc_id, data.terraform_remote_state.main_vpc.outputs.vpc_id)
}

output "main_vpc_cidr" {
  description = "메인 VPC CIDR 블록"
  value       = coalesce(var.main_vpc_cidr, data.terraform_remote_state.main_vpc.outputs.vpc_cidr)
}

# 이 출력 전체를 삭제하거나 주석 처리
# output "openvpn_routing_update_instructions" {
#   description = "OpenVPN 라우팅 업데이트 지침"
#   value       = <<-EOT
#     ==========[ OpenVPN 라우팅 업데이트 지침 ]==========
#     
#     1. OpenVPN 서버에 SSH로 접속하세요:
#        ssh -i /path/to/${var.key_name}.pem ec2-user@${aws_eip.openvpn.public_ip}
#        
#     2. 다음 명령을 실행하여 메인 VPC CIDR을 라우팅 설정에 추가하세요:
#        sudo /usr/local/openvpn_as/scripts/sacli --key "vpn.server.routing.private_network.1" --value "${coalesce(var.main_vpc_cidr, data.terraform_remote_state.main_vpc.outputs.vpc_cidr)}" ConfigPut
#        sudo /usr/local/openvpn_as/scripts/sacli start
#        
#     3. VPN 클라이언트에 재연결하여 새 라우팅 설정을 적용하세요.
#   EOT
# }

output "post_deployment_guide" {
  description = "배포 후 접속 및 환경 설정 가이드"
  value       = <<-EOT
    ==========[ 배포 후 접속 및 환경 설정 가이드 ]==========
    
    1. SSH로 OpenVPN 서버 접속 (주의: 사용자 이름은 반드시 'openvpnas'입니다)
       $ ssh -i /path/to/${var.key_name}.pem openvpnas@${aws_eip.openvpn.public_ip}
    
    2. OpenVPN 관리자 비밀번호 변경 (password 로 비밀번호 변경)(보안을 위해 반드시 변경하세요)
       $ sudo /usr/local/openvpn_as/scripts/sacli --user openvpn --new_pass password SetLocalPassword
    
    3. AWS CLI 및 kubectl 디렉토리 권한 설정 (필요한 경우)
       $ sudo mkdir -p /home/openvpnas/.aws /home/openvpnas/.kube
       $ sudo chown -R openvpnas:openvpnas /home/openvpnas/.aws /home/openvpnas/.kube
       $ sudo chmod 700 /home/openvpnas/.aws /home/openvpnas/.kube
    
    4. EKS 클러스터 컨피그 업데이트
       $ aws eks update-kubeconfig --name ${data.terraform_remote_state.compute.outputs.cluster_id} --region ${local.aws_region}
    
    5. 클러스터 연결 확인
       $ kubectl get nodes
       $ kubectl get pods -A
    
    6. VPC 간 연결 확인 (메인 VPC와 액세스 VPC 간)
       # 메인 VPC의 프라이빗 서브넷 내 리소스 IP로 핑 테스트
       $ ping <메인_VPC_프라이빗_IP>
       
       # 또는 traceroute로 경로 확인
       $ sudo traceroute -I <메인_VPC_프라이빗_IP>
       
       # 또는 Transit Gateway 경로 테이블 확인
       $ aws ec2 describe-transit-gateway-route-tables --transit-gateway-route-table-ids ${aws_ec2_transit_gateway.this.association_default_route_table_id} --region ${local.aws_region}
    
    7. VPN 클라이언트 사용자 생성 및 연결 확인
       # OpenVPN 관리자 웹 UI에서 사용자 생성 (https://${aws_eip.openvpn.public_ip}:943/admin)
       # VPN 연결 후 다음 명령으로 라우팅 확인
       $ ip route
       
       # 메인 VPC CIDR이 라우팅 테이블에 있는지 확인
       # 메인 VPC CIDR: ${coalesce(var.main_vpc_cidr, data.terraform_remote_state.main_vpc.outputs.vpc_cidr)}
    =================================================
  EOT
} 