# Jenkins Helm 차트 배포를 위한 테라폼 모듈
# EKS 클러스터에 Jenkins를 설치합니다

# Kubernetes 네임스페이스 생성
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace # 변수로 전달받은 네임스페이스 이름 사용

    labels = {
      name        = var.namespace
      environment = var.environment # 개발, 스테이징, 프로덕션 등 환경 정보
      managed-by  = "terraform"     # 테라폼으로 관리됨을 표시
    }
  }
}

# Jenkins를 위한 서비스 계정 생성
resource "kubernetes_service_account" "jenkins" {
  metadata {
    name      = "jenkins"                                     # 서비스 계정 이름
    namespace = kubernetes_namespace.jenkins.metadata[0].name # 위에서 만든 네임스페이스 참조

    annotations = {
      # AWS IAM Role과 연결하기 위한 IRSA(IAM Roles for Service Accounts) 어노테이션
      "eks.amazonaws.com/role-arn" = aws_iam_role.jenkins_role.arn
    }

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/managed-by" = "terraform" # 테라폼으로 관리됨을 표시
    }
  }

  depends_on = [kubernetes_namespace.jenkins] # 네임스페이스가 먼저 생성되어야 함
}

# Jenkins를 위한 IRSA 설정 (IAM Role)
resource "aws_iam_role" "jenkins_role" {
  name = "${var.name_prefix}-jenkins-role" # IAM 역할 이름

  # OIDC 신뢰 관계 정책 (EKS 서비스 계정이 이 역할을 수임할 수 있도록 함)
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = var.oidc_provider_arn # EKS OIDC 제공자 ARN
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          # 특정 네임스페이스의 jenkins 서비스 계정만 역할 수임 가능
          "${trimprefix(var.oidc_provider_arn, "arn:aws:iam::[0-9]*:oidc-provider/")}:sub" : "system:serviceaccount:${kubernetes_namespace.jenkins.metadata[0].name}:jenkins"
        }
      }
    }]
  })

  tags = var.tags # 리소스에 태그 추가
}

# 정책 연결
resource "aws_iam_role_policy_attachment" "jenkins_policy_attachment" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_policy.arn # 아래에서 생성한 정책 연결
}

# Jenkins를 위한 IAM 정책 생성 (AWS 리소스 접근 권한)
resource "aws_iam_policy" "jenkins_policy" {
  name        = "${var.name_prefix}-jenkins-policy"
  description = "Jenkins 서버에 필요한 IAM 권한"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # EC2 태그 읽기 권한 (인스턴스 검색용)
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          # EBS 볼륨 관련 권한 추가
          "ec2:CreateVolume",
          "ec2:DeleteVolume",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumeStatus",
          "ec2:DescribeVolumeAttribute",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot",
          "ec2:DescribeSnapshots",
          "ec2:ModifyVolume"
        ]
        Resource = "*"
      },
      {
        # ECR 권한 (도커 이미지 푸시용) - 백엔드 빌드 관련 권한
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken", # ECR 인증 토큰 발급
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          # 백엔드 Jenkinsfile에 필요한 추가 권한
          "ecr:ListImages",
          "ecr:DescribeRepositories",
          "ecr:TagResource",
          "sts:GetCallerIdentity" # AWS_ACCOUNT_ID 가져오기 위한 권한
        ]
        Resource = "*"
      },
      {
        # EKS 클러스터 접근 권한
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })
}

# 커스텀 스토리지 클래스 생성
resource "kubernetes_storage_class" "jenkins_immediate" {
  metadata {
    name = var.storage_class_name  # local.tf에서 지정한 "fucking-storage-class" 사용
  }
  
  storage_provisioner = "ebs.csi.aws.com"
  parameters = {
    type   = "gp2"
    fsType = "ext4"
  }
  volume_binding_mode = "Immediate"
  reclaim_policy      = "Retain"
}

# Jenkins용 PVC 생성 - Helm 호환 라벨 및 어노테이션 추가
resource "kubernetes_persistent_volume_claim" "jenkins_pvc" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    
    # Helm 호환 라벨로 수정
    labels = {
      "app.kubernetes.io/component" = "jenkins-controller"
      "app.kubernetes.io/instance"  = "jenkins"
      "app.kubernetes.io/name"      = "jenkins"
      "app.kubernetes.io/managed-by" = "Helm"  # 여기가 핵심 - Terraform이 아닌 Helm으로 설정
    }
    
    # Helm 필수 어노테이션 추가
    annotations = {
      "meta.helm.sh/release-name"      = "jenkins"  # Helm 릴리스 이름
      "meta.helm.sh/release-namespace" = kubernetes_namespace.jenkins.metadata[0].name  # 네임스페이스
    }
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.jenkins_pvc_size  # local.tf에서 정의된 20Gi 사용
      }
    }
    storage_class_name = var.storage_class_name
  }
}

# Jenkins Helm 차트 배포
resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.jenkins_chart_version
  namespace  = kubernetes_namespace.jenkins.metadata[0].name

  # values.yaml 템플릿에 PVC 이름 추가
  values = [templatefile("${path.module}/files/values.yaml", {
    jenkins_service_type = var.jenkins_service_type
    service_account_name = kubernetes_service_account.jenkins.metadata[0].name
    jenkins_namespace    = kubernetes_namespace.jenkins.metadata[0].name
    ingress_enabled      = var.ingress_enabled
    ingress_host         = var.ingress_host
    ingress_class        = var.ingress_class
    jenkins_admin_user   = var.jenkins_admin_user
    storage_class_name   = var.storage_class_name
    jenkins_pvc_name     = kubernetes_persistent_volume_claim.jenkins_pvc.metadata[0].name
  })]

  # 민감한 정보는 set_sensitive를 통해 설정
  set_sensitive {
    name  = "controller.adminPassword"
    value = var.jenkins_admin_password # 관리자 비밀번호 (민감 정보)
  }
  
  # timeout = 300 # 450초 동안 대기

  # 의존성 설정 추가 - PVC가 생성된 후에 Helm 배포
  depends_on = [
    kubernetes_namespace.jenkins,
    kubernetes_service_account.jenkins,
    kubernetes_storage_class.jenkins_immediate,
    kubernetes_persistent_volume_claim.jenkins_pvc,
    kubernetes_config_map.jenkins_config,
    kubernetes_config_map.jenkins_jobs
  ]
}
