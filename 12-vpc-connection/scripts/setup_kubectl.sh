#!/bin/bash

# 시스템 타입 감지 및 패키지 관리자 설정
if [ -f /etc/debian_version ]; then
  # Ubuntu/Debian 계열
  echo "Ubuntu/Debian 계열 시스템 감지됨"
  apt-get update -y
  apt-get install -y unzip curl awscli
  PKG_MANAGER="apt-get"
else
  # Amazon Linux/RHEL 계열
  echo "Amazon Linux/RHEL 계열 시스템 감지됨"
  dnf update -y
  dnf install -y unzip curl
  # Amazon Linux에서는 pip를 통해 설치
  dnf install -y python3-pip
  pip3 install awscli
  PKG_MANAGER="dnf"
fi

# AWS CLI 설치 확인
echo "AWS CLI 설치 확인:"
aws --version

# kubectl 설치
echo "kubectl 설치 중..."
cd /tmp
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# kubectl 설치 확인
echo "kubectl 설치 확인:"
kubectl version --client

# 사용자 디렉토리 설정 - 권한 문제 해결
echo "사용자 디렉토리 권한 설정..."
mkdir -p /home/openvpnas/.aws
mkdir -p /home/openvpnas/.kube
chown -R openvpnas:openvpnas /home/openvpnas/.aws
chown -R openvpnas:openvpnas /home/openvpnas/.kube
chmod 700 /home/openvpnas/.aws
chmod 700 /home/openvpnas/.kube

# AWS 및 kubectl 자동완성 설정
echo 'source <(kubectl completion bash)' >> /home/openvpnas/.bashrc
echo 'complete -C "$(which aws_completer)" aws' >> /home/openvpnas/.bashrc
chown openvpnas:openvpnas /home/openvpnas/.bashrc

# AWS 기본 리전 설정
echo '[default]' > /home/openvpnas/.aws/config
echo 'region = ${aws_region}' >> /home/openvpnas/.aws/config
echo 'output = json' >> /home/openvpnas/.aws/config

echo "AWS CLI 및 kubectl 설치 완료" 