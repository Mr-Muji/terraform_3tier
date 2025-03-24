/**
 * CICD 모듈
 * 
 * 이 모듈은 다음 기능을 제공합니다:
 * 1. AWS ECR 저장소 - 백엔드 및 프론트엔드 이미지 저장
 * 2. ArgoCD - 쿠버네티스 배포를 위한 GitOps 도구
 * 3. ECR과 ArgoCD 간의 통합 - 프론트엔드 애플리케이션 배포
 * 
 * 작성자: 인프라팀
 * 최종 수정일: 2023-08-01
 */

#-------------------------------------------------------
# 1. AWS ECR 저장소 - 백엔드 및 프론트엔드 도커 이미지 저장을 위한 리소스
#-------------------------------------------------------

# 백엔드 ECR 저장소 생성
resource "aws_ecr_repository" "backend_repo" {
  name                 = "${var.ecr_name}-backend"  # 저장소 이름에 backend 접미사 추가
  image_tag_mutability = var.image_tag_mutability   # 이미지 태그 변경 가능 여부 (MUTABLE/IMMUTABLE)

  # 이미지 취약점 스캔 설정
  image_scanning_configuration {
    scan_on_push = var.scan_on_push  # 이미지 업로드 시 자동 스캔 여부
  }

  # 저장소 암호화 설정
  encryption_configuration {
    encryption_type = var.encryption_type  # AES256 또는 KMS
  }

  # 리소스 태그 설정
  tags = merge(var.common_tags, {
    Name = "${var.ecr_name}-backend"
  })

  force_delete = true  # 이미지가 있어도 강제 삭제
}

# 프론트엔드 ECR 저장소 생성
resource "aws_ecr_repository" "frontend_repo" {
  name                 = "${var.ecr_name}-frontend"  # 저장소 이름에 frontend 접미사 추가
  image_tag_mutability = var.image_tag_mutability

  # 이미지 취약점 스캔 설정
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  # 저장소 암호화 설정
  encryption_configuration {
    encryption_type = var.encryption_type
  }

  # 리소스 태그 설정
  tags = merge(var.common_tags, {
    Name = "${var.ecr_name}-frontend"
  })

  force_delete = true  # 이미지가 있어도 강제 삭제
}

# 백엔드 저장소 수명 주기 정책 - 이미지 자동 정리
resource "aws_ecr_lifecycle_policy" "backend_repo_policy" {
  repository = aws_ecr_repository.backend_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "최신 이미지 10개만 유지하고 나머지는 자동 삭제"
        selection = {
          tagStatus     = "any"           # 모든 태그에 적용
          countType     = "imageCountMoreThan"
          countNumber   = 10              # 10개 이상일 때 가장 오래된 이미지 삭제
        }
        action = {
          type = "expire"                 # 만료 처리
        }
      }
    ]
  })
}

# 프론트엔드 저장소 수명 주기 정책 - 이미지 자동 정리
resource "aws_ecr_lifecycle_policy" "frontend_repo_policy" {
  repository = aws_ecr_repository.frontend_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "최신 이미지 10개만 유지하고 나머지는 자동 삭제"
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

#-------------------------------------------------------
# 2. ArgoCD 설치 및 기본 설정
#-------------------------------------------------------

# ArgoCD 네임스페이스 생성
resource "kubernetes_namespace" "argocd" {
  count = var.install_argocd ? 1 : 0  # install_argocd 변수가 true일 때만 생성

  provider = kubernetes.post_cluster

  metadata {
    name = var.argocd_namespace  # 네임스페이스 이름 (기본값: argocd)
    
    labels = {
      "managed-by" = "terraform"  # 관리 도구 표시
    }
    
    # 삭제 시 문제 방지를 위한 설정
    annotations = {
      "argocd.argoproj.io/sync-options" = "Prune=false"
      "kubectl.kubernetes.io/deletion-grace-period" = "30"
    }
  }
  
  # 삭제 시 오류 방지
  lifecycle {
    create_before_destroy = true
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
  
  timeout    = 1800  # 30분 (설치 시간이 오래 걸릴 수 있음)
  
  # templates/argocd-values.yaml 파일 사용
  values = [
    templatefile("${path.module}/templates/argocd-values.yaml", {
      ingress_enabled     = var.ingress_enabled
      domain_name         = var.domain_name
      ingress_host        = var.ingress_host
      ingress_class       = var.ingress_class
      ingress_annotations = jsonencode(merge(var.ingress_annotations, {
        "alb.ingress.kubernetes.io/group.name" = "argocd"
      }))
      helm_charts_repo_url = var.helm_charts_repo_url
      admin_password_hash = var.argocd_admin_password_hash
    })
  ]
  
  # 충돌 해결 옵션
  atomic          = true  # 설치 실패 시 자동 롤백
  cleanup_on_fail = true  # 실패한 설치의 리소스 정리
  wait            = true  # 모든 리소스가 준비될 때까지 대기
  
  # EKS 클러스터가 준비된 후에만 설치
  depends_on = [
    kubernetes_namespace.argocd
  ]
}

# ArgoCD CRD 적용 후 대기 시간 설정
# CRD가 완전히 등록되어야 Application 리소스를 생성할 수 있음
resource "time_sleep" "wait_for_crds" {
  count = var.install_argocd ? 1 : 0
  
  depends_on = [helm_release.argocd]
  create_duration = "30s"  # 30초 대기 (환경에 따라 조정 필요)
}

#-------------------------------------------------------
# 3. 프론트엔드 애플리케이션 배포 설정
#-------------------------------------------------------

# 프론트엔드 네임스페이스 생성
resource "kubernetes_namespace" "frontend" {
  count = var.install_argocd ? 1 : 0

  metadata {
    name = var.frontend_namespace  # 네임스페이스 이름 (기본값: frontend)
    
    labels = {
      "managed-by" = "terraform"
      "app"        = "frontend"
    }
    
    # 삭제 시 문제 방지를 위한 설정
    annotations = {
      "kubectl.kubernetes.io/deletion-grace-period" = "30"
    }
  }

  depends_on = [
    helm_release.argocd  # ArgoCD 설치 후 생성
  ]
  
  # 삭제 시 오류 방지
  lifecycle {
    create_before_destroy = true
  }
}

# AWS ECR 접근을 위한 이미지 풀 시크릿 생성
# 쿠버네티스에서 프라이빗 ECR 저장소의 이미지를 가져오기 위해 필요
resource "kubernetes_secret" "ecr_auth" {
  count = var.install_argocd ? 1 : 0
  
  metadata {
    name      = "ecr-auth"  # 시크릿 이름
    namespace = kubernetes_namespace.frontend[0].metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"  # Docker 레지스트리 인증 타입

  # ECR 인증 정보 구성
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${aws_ecr_repository.frontend_repo.repository_url}" = {
          auth = base64encode("AWS:${var.ecr_auth_token}")  # AWS ECR 인증 토큰
        }
      }
    })
  }

  depends_on = [
    kubernetes_namespace.frontend
  ]
}

# ArgoCD Application 리소스 생성 (GitOps 파이프라인 구성)
resource "kubernetes_manifest" "frontend_application" {
  count = var.install_argocd && var.helm_charts_repo_url != "" ? 1 : 0
  
  provider = kubernetes.post_cluster

  # Application 리소스 정의
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "frontend"  # 애플리케이션 이름
      namespace = kubernetes_namespace.argocd[0].metadata[0].name  # ArgoCD 네임스페이스
    }
    spec = {
      # 프로젝트 설정
      project = "default"  # ArgoCD 프로젝트 (기본값: default)
      
      # 소스 설정
      source = {
        # Git 저장소 설정
        repoURL        = var.git_repo_url != "" ? var.git_repo_url : "https://github.com/argoproj/argocd-example-apps"
        targetRevision = var.git_target_revision  # 브랜치 또는 태그
        path           = var.git_repo_url != "" ? var.frontend_manifest_path : "guestbook"
        
        # Helm 차트 파라미터 - ECR 이미지 설정
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
      
      # 배포 대상 설정
      destination = {
        server    = "https://kubernetes.default.svc"  # 기본 쿠버네티스 API 서버
        namespace = var.frontend_namespace            # 배포 네임스페이스
      }
      
      # 동기화 정책 설정
      syncPolicy = {
        automated = {
          prune      = true       # 불필요한 리소스 자동 제거
          selfHeal   = true       # 변경 사항 자동 복구
          allowEmpty = false      # 빈 상태로 동기화 허용 안 함
        }
        syncOptions = [
          "CreateNamespace=true"  # 네임스페이스 자동 생성
        ]
      }
    }
  }

  # 의존성 설정
  depends_on = [
    helm_release.argocd,          # ArgoCD 설치 완료
    kubernetes_namespace.frontend, # 프론트엔드 네임스페이스 생성
    kubernetes_secret.ecr_auth,    # ECR 인증 시크릿 생성
    time_sleep.wait_for_crds       # CRD 적용 대기
  ]
  
  # 리소스 삭제 순서 관리 - 가장 먼저 삭제되도록 설정
  lifecycle {
    create_before_destroy = true
  }
}

# EKS 클러스터 준비 대기
resource "time_sleep" "wait_for_eks" {
  count = var.install_argocd ? 1 : 0
  
  create_duration = "30s"  # 클러스터 준비를 위한 추가 대기 시간
}

# 안전한 초기화를 위한 null_resource 추가
resource "null_resource" "wait_for_cluster" {
  count = var.install_argocd ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
      aws eks wait cluster-active --name ${var.eks_cluster_id} --region ${var.region}
      aws eks update-kubeconfig --name ${var.eks_cluster_id} --region ${var.region}
      kubectl wait --for=condition=available --timeout=5m -n kube-system deployment/coredns
    EOT
  }

  # 실제 리소스에 대한 의존성으로 변경
  depends_on = [time_sleep.wait_for_eks]
}

# ArgoCD App of Apps 루트 애플리케이션 생성
resource "kubernetes_manifest" "root_application" {
  # 클러스터 없이 첫 단계 배포 시 오류 방지
  count = 0  # var.install_argocd && var.helm_charts_repo_url != "" ? 1 : 0
  provider = kubernetes.post_cluster
  
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "root-application"
      namespace = kubernetes_namespace.argocd[0].metadata[0].name
      # finalizer 제거하여 삭제 문제 방지
      finalizers = []
    }
    spec = {
      project = "default"
      
      # 소스 설정 - Helm 차트 저장소
      source = {
        repoURL        = var.helm_charts_repo_url  # 헬름 차트 저장소 URL
        targetRevision = var.helm_charts_revision  # 브랜치 또는 태그
        path           = var.helm_charts_repo_path  # 루트 애플리케이션 차트 경로
        
        # Helm 설정 - 환경 변수 전달
        helm = {
          values = yamlencode({
            # 전역 환경 설정 - 모든 하위 앱에 전달됨
            global = {
              environment = var.environment
              domain      = var.domain_name
              repositories = {
                frontend = aws_ecr_repository.frontend_repo.repository_url
                backend  = aws_ecr_repository.backend_repo.repository_url
              }
            }
          })
        }
      }
      
      # 배포 대상 설정
      destination = {
        server    = "https://kubernetes.default.svc"  # 현재 클러스터
        namespace = "argocd"  # ArgoCD 네임스페이스
      }
      
      # 동기화 정책 구조
      syncPolicy = {
        automated = {
          prune       = true
          selfHeal    = true
          allowEmpty  = false
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }
  
  # 삭제 시 오류 방지
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      manifest.metadata,
      manifest.spec.source,
      manifest.spec.destination
    ]
  }

  # EKS 클러스터가 준비된 후에만 생성
  depends_on = [
    
    helm_release.argocd,
    time_sleep.wait_for_crds,
    kubernetes_namespace.argocd,
    time_sleep.wait_for_eks[0]  # 클러스터 준비 대기
  ]
}

# 아르고CD 인그레스 데이터 소스 수정
data "kubernetes_ingress_v1" "argocd_ingress" {
  count = var.install_argocd && var.ingress_enabled ? 1 : 0
  
  depends_on = [helm_release.argocd]
  
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd[0].metadata[0].name
  }
}

# ArgoCD용 Route 53 DNS 레코드 생성 - 안전한 참조 처리
resource "aws_route53_record" "argocd" {
  count = var.install_argocd && var.ingress_enabled && var.zone_id != "" ? 1 : 0
  
  zone_id = var.zone_id
  name    = var.ingress_host
  type    = "CNAME"
  ttl     = 300
  
  # 안전한 레코드 처리 (try 함수 사용)
  records = try(
    [data.kubernetes_ingress_v1.argocd_ingress[0].status[0].load_balancer[0].ingress[0].hostname],
    ["dummy.${var.domain_name}"]
  )
  
  # 삭제 시 의존성 문제 방지
  lifecycle {
    create_before_destroy = true
    ignore_changes = [records]
  }
}

# 프론트엔드 인그레스 데이터 소스 수정
data "kubernetes_ingress_v1" "frontend_ingress" {
  count = var.install_argocd && var.zone_id != "" ? 1 : 0
  
  depends_on = [kubernetes_manifest.root_application]
  
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.frontend[0].metadata[0].name
  }
}

# 프론트엔드용 Route 53 DNS 레코드 생성 - 안전한 참조 처리
resource "aws_route53_record" "frontend" {
  count = var.install_argocd && var.zone_id != "" ? 1 : 0
  
  zone_id = var.zone_id
  name    = var.frontend_ingress_host  # 이미 var.domain_name으로 변경됨
  type    = "CNAME"
  ttl     = 300
  
  # 안전한 레코드 처리 (try 함수 사용)
  records = try(
    [data.kubernetes_ingress_v1.frontend_ingress[0].status[0].load_balancer[0].ingress[0].hostname],
    ["dummy.${var.domain_name}"]
  )
  
  # 삭제 시 의존성 문제 방지
  lifecycle {
    create_before_destroy = true
    ignore_changes = [records]
  }
}

# ECR 저장소에 있는 이미지를 삭제하기 위한 리소스
resource "null_resource" "ecr_cleanup" {
  count = var.ecr_force_delete ? 1 : 0
  
  triggers = {
    frontend_repo_name = aws_ecr_repository.frontend_repo.name
    backend_repo_name = aws_ecr_repository.backend_repo.name
  }
  
  # 삭제 전 ECR 이미지 정리
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "ECR 이미지 정리 중..."
      # 저장소 URL이 아닌 이름을 사용
      aws ecr batch-delete-image --repository-name ${self.triggers.frontend_repo_name} --image-ids "$(aws ecr list-images --repository-name ${self.triggers.frontend_repo_name} --query 'imageIds[*]' --output json)" || true
      aws ecr batch-delete-image --repository-name ${self.triggers.backend_repo_name} --image-ids "$(aws ecr list-images --repository-name ${self.triggers.backend_repo_name} --query 'imageIds[*]' --output json)" || true
      echo "ECR 이미지 정리 완료"
    EOT
  }
  
  depends_on = [
    aws_ecr_repository.frontend_repo,
    aws_ecr_repository.backend_repo
  ]
}

# 쿠버네티스 네임스페이스 리소스 정리를 위한 null 리소스
resource "null_resource" "argocd_cleanup" {
  count = var.install_argocd ? 1 : 0
  
  # 삭제 전 ArgoCD 애플리케이션 정리
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "ArgoCD 애플리케이션 정리 중..."
      kubectl patch application root-application -n argocd --type json -p='[{"op": "remove", "path": "/metadata/finalizers"}]' || true
      kubectl delete application root-application -n argocd --cascade=foreground --wait=false || true
      echo "ArgoCD 애플리케이션 정리 완료"
    EOT
  }
  
  depends_on = [
    kubernetes_manifest.root_application
  ]
}