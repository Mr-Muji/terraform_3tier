/**
 * ECR 저장소 생성을 위한 모듈
 * 백엔드 이미지를 저장할 저장소를 생성합니다.
 */

# ECR 저장소 생성
resource "aws_ecr_repository" "backend_repo" {
  name                 = "${var.ecr_name}-backend"  # 백엔드 접미사 추가
  image_tag_mutability = var.image_tag_mutability

  # 이미지 스캔 설정
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  # 암호화 설정
  encryption_configuration {
    encryption_type = var.encryption_type
  }

  # 태그
  tags = merge(var.common_tags, {
    Name = "${var.ecr_name}-backend"
  })
}

# 수명 주기 정책 설정 (선택 사항)
resource "aws_ecr_lifecycle_policy" "backend_repo_policy" {
  repository = aws_ecr_repository.backend_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "최신 이미지 10개만 유지"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# 프론트엔드 ECR 저장소 생성
resource "aws_ecr_repository" "frontend_repo" {
  name                 = "${var.ecr_name}-frontend"  # 기존 코드 유지
  image_tag_mutability = var.image_tag_mutability

  # 이미지 스캔 설정
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  # 암호화 설정
  encryption_configuration {
    encryption_type = var.encryption_type
  }

  # 태그
  tags = merge(var.common_tags, {
    Name = "${var.ecr_name}-frontend"
  })
}

# 프론트엔드 수명 주기 정책 설정
resource "aws_ecr_lifecycle_policy" "frontend_repo_policy" {
  repository = aws_ecr_repository.frontend_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "최신 이미지 10개만 유지"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# -----------------------------------------------------
# ArgoCD 설치 부분 (새로 추가)
# -----------------------------------------------------

# ArgoCD 네임스페이스 생성
resource "kubernetes_namespace" "argocd" {
  count = var.install_argocd ? 1 : 0

  metadata {
    name = var.argocd_namespace
    
    labels = {
      "managed-by" = "terraform"
    }
  }
}

# ArgoCD 설치 - Helm 차트 사용
resource "helm_release" "argocd" {
  count = var.install_argocd ? 1 : 0

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace.argocd[0].metadata[0].name

  # 기본 설정값 덮어쓰기
  values = [
    templatefile("${path.module}/templates/argocd-values.yaml", {
      admin_password_hash = var.argocd_admin_password_hash
      ingress_enabled     = var.ingress_enabled
      ingress_host        = var.ingress_host
      ingress_class       = var.ingress_class
      ingress_annotations = jsonencode(var.ingress_annotations)
    })
  ]

  depends_on = [
    kubernetes_namespace.argocd
  ]

  # 중요: 모든 관련 리소스가 삭제된 후 차트 제거
  lifecycle {
    create_before_destroy = false
  }
}

# 프론트엔드 네임스페이스 생성
resource "kubernetes_namespace" "frontend" {
  count = var.install_argocd ? 1 : 0

  metadata {
    name = var.frontend_namespace
    
    labels = {
      "managed-by" = "terraform"
    }
  }
}

# AWS ECR 접근을 위한 시크릿 생성
resource "kubernetes_secret" "ecr_auth" {
  count = var.install_argocd ? 1 : 0
  
  metadata {
    name      = "ecr-auth"
    namespace = kubernetes_namespace.frontend[0].metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${aws_ecr_repository.frontend_repo.repository_url}" = {
          auth = base64encode("AWS:${var.ecr_auth_token}")
        }
      }
    })
  }
}

# ECR용 매니페스트 템플릿 생성
resource "local_file" "frontend_manifest" {
  count = var.install_argocd ? 1 : 0
  
  content = templatefile("${path.module}/templates/frontend-deployment.yaml", {
    ecr_repo_url      = aws_ecr_repository.frontend_repo.repository_url
    image_tag         = var.frontend_image_tag
    frontend_namespace = var.frontend_namespace
    ingress_host      = var.frontend_ingress_host
    ecr_secret_name   = kubernetes_secret.ecr_auth[0].metadata[0].name
  })
  
  filename = "${path.module}/generated/frontend-deployment.yaml"
}

# 시간 지연 추가
resource "time_sleep" "wait_for_crds" {
  count = var.install_argocd ? 1 : 0
  
  depends_on = [helm_release.argocd]
  create_duration = "30s"
}

# Application 리소스 생성 전에 시간 지연 추가
resource "kubernetes_manifest" "frontend_application" {
  count = 0  # 임시로 비활성화 (원래: var.install_argocd ? 1 : 0)

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "frontend"
      namespace = kubernetes_namespace.argocd[0].metadata[0].name
    }
    spec = {
      project = "default"
      source = {
        # Git 저장소가 있는 경우
        repoURL        = var.git_repo_url != "" ? var.git_repo_url : "https://github.com/argoproj/argocd-example-apps"
        targetRevision = var.git_target_revision
        path           = var.git_repo_url != "" ? var.frontend_manifest_path : "guestbook"
        
        # ECR 이미지를 직접 사용하는 경우의 추가 설정
        helm = {
          parameters = [
            {
              name  = "image.repository"
              value = aws_ecr_repository.frontend_repo.repository_url
            },
            {
              name  = "image.tag"
              value = var.frontend_image_tag
            }
          ]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.frontend_namespace
      }
      syncPolicy = {
        automated = {
          prune      = true
          selfHeal   = true
          allowEmpty = false
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  depends_on = [
    helm_release.argocd,
    kubernetes_namespace.frontend,
    kubernetes_secret.ecr_auth,
    time_sleep.wait_for_crds
  ]
  
  # 중요: 삭제할 때 먼저 제거되도록 라이프사이클 설정 추가
  lifecycle {
    create_before_destroy = true
  }
}