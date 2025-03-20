#---------------------------------------
# EKS 클러스터 생성 (오토 모드)
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

# 워커 노드 최소 정책 연결
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodeMinimalPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.node.name
}

# ECR 이미지 가져오기 정책 연결
resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryPullOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.node.name
}

# 추가: CNI 정책 연결 (네트워킹 기능을 위해 필요)
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
  
  depends_on = [aws_eks_cluster.this, aws_eks_node_group.general_purpose]
}

# CoreDNS 애드온 - DNS 서비스
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "coredns"
  
  resolve_conflicts_on_create = "OVERWRITE"
  
  tags = {
    Environment = var.environment
  }
  
  # 애드온 설치 전에 노드 그룹이 존재해야 합니다
  # 노드 그룹 생성 후 주석 해제
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
  depends_on = [
    aws_eks_cluster.this,
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodeMinimalPolicy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryPullOnly,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy
  ]
  
  # 노드 그룹 업데이트 시 새 노드 그룹 생성 후 기존 노드 그룹 삭제
  lifecycle {
    create_before_destroy = true
  }
}