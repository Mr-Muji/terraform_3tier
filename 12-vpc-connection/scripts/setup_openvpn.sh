#!/bin/bash

# OpenVPN 서버 자동 설정
echo "OpenVPN 서버 설정 중..."
sleep 30  # OpenVPN 서비스가 시작될 때까지 대기

# OpenVPN 클라이언트 라우팅 설정 변경 (VPC 접근 가능하도록)
/usr/local/openvpn_as/scripts/sacli --key "vpn.client.routing.reroute_gw" --value "true" ConfigPut
/usr/local/openvpn_as/scripts/sacli --key "vpn.server.routing.private_network.0" --value "${access_vpc_cidr}" ConfigPut

# 메인 VPC CIDR도 라우팅 테이블에 추가
/usr/local/openvpn_as/scripts/sacli --key "vpn.server.routing.private_network.1" --value "${main_vpc_cidr}" ConfigPut

# 변경사항 적용
/usr/local/openvpn_as/scripts/sacli start

echo "OpenVPN 설정 완료됨" 