#---------------------------------------
# EKS 클러스터 생성
#---------------------------------------
resource "aws_eks_cluster" "this" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  # VPC 구성
  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = var.additional_security_group_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  # 클러스터 로깅 설정 (선택사항)
  enabled_cluster_log_types = var.enabled_cluster_log_types

  # 태그 설정
  tags = merge(
    {
      Name        = var.eks_cluster_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  # IAM 역할 정책이 먼저 생성되고 클러스터가 삭제된 후에 삭제되도록 의존성 설정
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSComputePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSBlockStoragePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSLoadBalancingPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSNetworkingPolicy,
  ]

  # 클러스터 삭제 전에 연결된 모든 노드 그룹이 삭제되도록 설정
  lifecycle {
    create_before_destroy = true
  }
}

#---------------------------------------
# EKS 클러스터 IAM 역할 및 정책
#---------------------------------------
resource "aws_iam_role" "cluster" {
  name = "eks-cluster-${var.project_name}"

  # 신뢰 관계 정의 - EKS 서비스가 이 역할을 맡을 수 있도록 허용
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "role-eks-cluster-${var.project_name}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 클러스터 정책 연결
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# 컴퓨트 정책 연결
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSComputePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
  role       = aws_iam_role.cluster.name
}

# 블록 스토리지 정책 연결
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSBlockStoragePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role       = aws_iam_role.cluster.name
}

# 로드 밸런싱 정책 연결
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSLoadBalancingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  role       = aws_iam_role.cluster.name
}

# 네트워킹 정책 연결
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSNetworkingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  role       = aws_iam_role.cluster.name
}

#---------------------------------------
# EKS 노드 IAM 역할 및 정책
#---------------------------------------
resource "aws_iam_role" "node" {
  name = "eks-node-${var.project_name}"

  # EC2 서비스가 이 역할을 맡을 수 있도록 허용
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "role-eks-node-${var.project_name}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 워커 노드 정책 연결 - 중복 제거 및 정책 이름 통일
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

# ECR 읽기 전용 정책 연결 - 일관된 이름 사용
resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

# CNI 정책 연결
resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

# CloudWatch 관찰성 애드온 설치 (선택사항)
resource "aws_eks_addon" "cw_observability" {
  count = var.enable_cloudwatch_observability ? 1 : 0

  cluster_name = aws_eks_cluster.this.name
  addon_name   = "amazon-cloudwatch-observability"

  # 충돌 해결 방법 설정
  resolve_conflicts_on_create = "OVERWRITE"

  tags = {
    Environment = var.environment
  }

  # 클러스터가 완전히 생성된 후에 애드온 설치
  depends_on = [aws_eks_cluster.this, aws_eks_node_group.general_purpose]
}

# VPC CNI 애드온 - 네트워킹
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"

  resolve_conflicts_on_create = "OVERWRITE"

  tags = {
    Environment = var.environment
  }

  # 노드 그룹 의존성 제거
  depends_on = [aws_eks_cluster.this]
}

# CoreDNS 애드온 - DNS 서비스
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "coredns"

  resolve_conflicts_on_create = "OVERWRITE"

  tags = {
    Environment = var.environment
  }

  # 노드 그룹 의존성 제거
  depends_on = [aws_eks_cluster.this, aws_eks_node_group.general_purpose]
}

# kube-proxy 애드온 - 네트워크 프록시
resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "kube-proxy"

  resolve_conflicts_on_create = "OVERWRITE"

  tags = {
    Environment = var.environment
  }

  depends_on = [aws_eks_cluster.this, aws_eks_node_group.general_purpose]
}

# EBS CSI 드라이버 - 블록 스토리지
resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "aws-ebs-csi-driver"

  resolve_conflicts_on_create = "OVERWRITE"

  tags = {
    Environment = var.environment
  }

  # 애드온 설치 전에 노드 그룹이 존재해야 합니다
  # 노드 그룹 생성 후 주석 해제
  depends_on = [aws_eks_node_group.general_purpose]
}

# EKS Pod Identity 에이전트 설치
resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "eks-pod-identity-agent"

  # 특정 버전을 지정하고 싶다면 아래 줄의 주석을 해제하고 버전을 지정하세요
  # addon_version = "v1.0.0-eksbuild.1"

  # 충돌 해결 방법 설정
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = {
    Name        = "addon-pod-identity-agent"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # 클러스터와 노드 그룹이 완전히 생성된 후에 애드온 설치
  depends_on = [
    aws_eks_cluster.this,
    aws_eks_node_group.general_purpose
  ]
}

# EKS 노드 그룹 생성
resource "aws_eks_node_group" "general_purpose" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "general-purpose"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids

  # 인스턴스 타입 및 디스크 설정
  instance_types = var.node_instance_types
  disk_size      = var.node_disk_size

  # 용량 타입 (ON_DEMAND 또는 SPOT)
  capacity_type = var.node_capacity_type

  # 오토 스케일링 설정
  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  # 업데이트 설정
  update_config {
    max_unavailable = 1
  }

  # AMI 타입 변경 - 더 안정적인 버전 사용
  ami_type = "AL2_x86_64"  # AL2023_x86_64_STANDARD 대신 더 안정적인 AMI 사용

  # 태그 설정
  tags = merge(
    {
      Name        = "ng-general-purpose-${var.eks_cluster_name}"
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  # 클러스터가 완전히 생성된 후에 노드 그룹 생성
  # 정책 이름 수정하여 의존성 문제 해결
  depends_on = [
    aws_eks_cluster.this,
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy
  ]

  # 노드 그룹 업데이트 시 새 노드 그룹 생성 후 기존 노드 그룹 삭제
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }
}

#---------------------------------------
# Kubernetes 네임스페이스 생성
#---------------------------------------
resource "kubernetes_namespace" "backend" {
  depends_on = [aws_eks_cluster.this]
  
  metadata {
    name = var.kubernetes_namespace
    
    labels = {
      "managed-by" = "terraform"
      "environment" = var.environment
    }
  }
}

#---------------------------------------
# AWS Load Balancer Controller IAM 역할 및 정책
#---------------------------------------
resource "aws_iam_policy" "lb_controller" {
  name        = "${var.eks_cluster_name}-lb-controller-policy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/policies/lb-controller-policy.json")
}

resource "aws_iam_role" "lb_controller" {
  name = "${var.eks_cluster_name}-lb-controller-role"
  
  # 신뢰 관계 정책을 정의합니다
  # 이 정책은 AWS Load Balancer Controller가 사용하는 서비스 계정이
  # 이 IAM 역할을 맡을 수 있도록 허용합니다
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          # 새로 생성한 OIDC 프로바이더를 참조합니다
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            # OIDC 토큰의 'sub' 클레임이 특정 서비스 계정과 일치하는지 확인합니다
            "${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
  
  # 리소스에 태그를 추가합니다
  tags = {
    Name        = "${var.eks_cluster_name}-lb-controller-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "lb_controller" {
  policy_arn = aws_iam_policy.lb_controller.arn
  role       = aws_iam_role.lb_controller.name
}

#---------------------------------------
# EKS OIDC Identity Provider 설정
#---------------------------------------
# 현재 AWS 계정 정보를 가져옵니다 (이미 정의되어 있다면 생략 가능)
data "aws_caller_identity" "current" {}

# EKS 클러스터의 OIDC 발급자 인증서의 지문을 가져옵니다
# 이 인증서는 AWS 서비스가 쿠버네티스 서비스 계정의 토큰을 신뢰할 수 있게 해줍니다
data "tls_certificate" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# AWS IAM OIDC 프로바이더 리소스를 생성합니다
# 이 프로바이더는 쿠버네티스 서비스 계정이 AWS IAM 역할을 맡을 수 있게 해줍니다
resource "aws_iam_openid_connect_provider" "eks" {
  # client_id_list는 OIDC 인증을 요청할 수 있는 클라이언트 목록입니다
  # sts.amazonaws.com은 AWS Security Token Service를 의미합니다
  client_id_list = ["sts.amazonaws.com"]
  
  # thumbprint_list는 신뢰할 수 있는 OIDC 발급자의 인증서 지문 목록입니다
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  
  # url은 OIDC 발급자의 URL입니다
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
  
  # 리소스에 태그를 추가합니다
  tags = {
    Name        = "${var.project_name}-eks-oidc-provider"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

#---------------------------------------
# AWS Load Balancer Controller 설치
#---------------------------------------
# Helm 차트로 AWS Load Balancer Controller 설치
resource "helm_release" "aws_load_balancer_controller" {
  # 릴리스 이름 (쿠버네티스 내에서의 이름)
  name = "aws-load-balancer-controller"
  
  # Helm 차트 저장소 - AWS EKS 차트를 제공하는 공식 저장소
  repository = "https://aws.github.io/eks-charts"
  
  # 설치할 차트 이름
  chart = "aws-load-balancer-controller"
  
  # 설치할 네임스페이스 - 시스템 구성요소는 kube-system에 설치
  namespace = "kube-system"
  
  # 차트 버전 - 특정 버전을 명시하면 재현 가능한 배포 보장
  version = "1.8.0"  # v2.12.0 컨트롤러와 호환되는 차트 버전
  
  # 설치 타임아웃 - 큰 클러스터에서는 설치에 시간이 더 걸릴 수 있음
  timeout = 900  # 15분
  
  # 차트의 Values 설정 (쿠버네티스 YAML의 values.yaml에 해당)
  set {
    # 대상 클러스터 이름 - 이 컨트롤러가 관리할 EKS 클러스터
    name  = "clusterName"
    value = aws_eks_cluster.this.name
  }
  
  set {
    # 커스텀 서비스 계정 사용 - 위에서 IAM 역할 연결을 위해 설정한 계정
    name  = "serviceAccount.create"
    value = "true"
  }
  
  set {
    # 서비스 계정 이름 설정 - IAM 역할 연결에 사용한 이름과 동일해야 함
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  
  set {
    # IAM 역할 ARN 주석 - 서비스 계정이 AWS 리소스에 접근할 수 있게 해줌
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.lb_controller.arn
  }
  
  set {
    # AWS 리전 설정 - 컨트롤러가 AWS API를 호출할 리전
    name  = "region"
    value = data.aws_region.current.name
  }
  
  set {
    # VPC ID 설정 - 컨트롤러가 리소스를 생성할 VPC
    name  = "vpcId"
    value = var.vpc_id
  }
  
  # 노드 그룹이 준비된 후 설치 - 노드가 없으면 파드를 스케줄링할 수 없음
  depends_on = [
    aws_eks_node_group.general_purpose,
    aws_iam_role_policy_attachment.lb_controller
  ]
}

# 현재 AWS 리전 정보 가져오기
data "aws_region" "current" {}
