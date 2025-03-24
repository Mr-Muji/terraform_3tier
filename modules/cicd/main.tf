/**
 * CICD 모듈
 * 
 * 이 모듈은 다음 기능을 제공합니다:
 * 1. AWS ECR 저장소 - 백엔드 및 프론트엔드 이미지 저장
 * 2. 프론트엔드 애플리케이션 배포 - 03단계에서 설치된 ArgoCD 활용
 */

#-------------------------------------------------------
# CICD 모듈 - ECR 저장소 및 프론트엔드 애플리케이션 배포
#-------------------------------------------------------

#-------------------------------------------------------
# ECR 저장소 생성 및 관리
#-------------------------------------------------------

# 프론트엔드 ECR 저장소 생성
resource "aws_ecr_repository" "frontend_repo" {
  name                 = "${var.prefix}-frontend"
  image_tag_mutability = var.image_tag_mutability
  
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  
  # 강제 삭제 설정 (개발환경에서만 권장)
  force_delete = var.ecr_force_delete
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.prefix}-frontend-repo"
      Component = "frontend"
    }
  )
}

# 백엔드 ECR 저장소 생성
resource "aws_ecr_repository" "backend_repo" {
  name                 = "${var.prefix}-backend"
  image_tag_mutability = var.image_tag_mutability
  
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  
  # 강제 삭제 설정 (개발환경에서만 권장)
  force_delete = var.ecr_force_delete
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.prefix}-backend-repo"
      Component = "backend"
    }
  )
}

# 프론트엔드 ECR 수명주기 정책
resource "aws_ecr_lifecycle_policy" "frontend_lifecycle" {
  repository = aws_ecr_repository.frontend_repo.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "최신 이미지 ${var.ecr_max_images}개만 유지"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.ecr_max_images
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# 백엔드 ECR 수명주기 정책
resource "aws_ecr_lifecycle_policy" "backend_lifecycle" {
  repository = aws_ecr_repository.backend_repo.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "최신 이미지 ${var.ecr_max_images}개만 유지"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.ecr_max_images
      }
      action = {
        type = "expire"
      }
    }]
  })
}

#-------------------------------------------------------
# 2. 외부 ArgoCD 인스턴스 참조 (이미 설치됨)
#-------------------------------------------------------

# 외부에서 설치된 ArgoCD 네임스페이스 참조
data "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

#-------------------------------------------------------
# 3. 프론트엔드 애플리케이션 배포 설정
#-------------------------------------------------------

# 프론트엔드 네임스페이스 생성
resource "kubernetes_namespace" "frontend" {
  metadata {
    name = var.frontend_namespace
  }
}

# AWS ECR 접근을 위한 이미지 풀 시크릿 생성
resource "kubernetes_secret" "ecr_auth" {
  metadata {
    name      = "ecr-auth"
    namespace = kubernetes_namespace.frontend.metadata[0].name
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

  depends_on = [kubernetes_namespace.frontend]
}

# 프론트엔드 애플리케이션 정의
resource "kubernetes_manifest" "frontend_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "frontend-app"
      namespace = data.kubernetes_namespace.argocd.metadata[0].name
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      project = "default"
      
      # 소스 설정
      source = {
        repoURL        = var.git_repo_url  # Git 저장소 URL
        targetRevision = var.git_target_revision  # Branch/Tag
        path           = var.frontend_manifest_path  # 매니페스트 경로

        # Helm 및 Kustomize 적용을 위한 추가 설정
        helm = {
          parameters = [
            {
              name  = "image.repository"
              value = aws_ecr_repository.frontend_repo.repository_url
            },
            {
              name  = "image.tag"
              value = var.frontend_image_tag
            },
            {
              name  = "ingress.host"
              value = var.frontend_ingress_host
            }
          ]
        }
      }
      
      # 배포 대상 설정
      destination = {
        server    = "https://kubernetes.default.svc"  # 현재 클러스터
        namespace = kubernetes_namespace.frontend.metadata[0].name
      }
      
      # 동기화 정책 설정
      syncPolicy = {
        automated = {
          prune       = true
          selfHeal    = true
          allowEmpty  = false
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
        retry = {
          limit = 5
          backoff = {
            duration    = "30s"
            maxDuration = "2m"
            factor      = 2
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.frontend]
}

# 프론트엔드 인그레스 데이터 소스
data "kubernetes_ingress_v1" "frontend_ingress" {
  metadata {
    name      = var.frontend_ingress_name
    namespace = kubernetes_namespace.frontend.metadata[0].name
  }
  
  depends_on = [kubernetes_manifest.frontend_application]
}

# 프론트엔드 인그레스가 완전히 프로비저닝될 때까지 대기
resource "time_sleep" "wait_for_frontend_ingress" {
  depends_on = [data.kubernetes_ingress_v1.frontend_ingress]
  create_duration = "10s"  # 더 긴 대기 시간 설정
}

# 로드 밸런서 ARN을 직접 가져오는 데이터 소스
data "external" "get_lb_arn" {
  count = var.zone_id != "" ? 1 : 0
  
  program = ["bash", "-c", <<-EOT
    LB_NAME=$(kubectl get ingress -n ${kubernetes_namespace.frontend.metadata[0].name} ${var.frontend_ingress_name} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' | cut -d'.' -f1 | cut -d'-' -f1)
    LB_ARN=$(aws elbv2 describe-load-balancers --region ${var.region} --names $LB_NAME --query 'LoadBalancers[0].LoadBalancerArn' --output text)
    DNS_NAME=$(aws elbv2 describe-load-balancers --region ${var.region} --names $LB_NAME --query 'LoadBalancers[0].DNSName' --output text)
    ZONE_ID=$(aws elbv2 describe-load-balancers --region ${var.region} --names $LB_NAME --query 'LoadBalancers[0].CanonicalHostedZoneId' --output text)
    echo "{\"arn\":\"$LB_ARN\",\"dns_name\":\"$DNS_NAME\",\"zone_id\":\"$ZONE_ID\"}"
  EOT
  ]
  
  depends_on = [data.kubernetes_ingress_v1.frontend_ingress, time_sleep.wait_for_frontend_ingress]
}

# Route 53 Alias 레코드 생성 - 안전하게 처리
resource "aws_route53_record" "frontend_alias" {
  count = var.zone_id != "" && length(data.external.get_lb_arn) > 0 ? 1 : 0
  
  zone_id = var.zone_id
  name    = var.frontend_ingress_host
  type    = "A"
  
  alias {
    name                   = data.external.get_lb_arn[0].result.dns_name
    zone_id                = data.external.get_lb_arn[0].result.zone_id
    evaluate_target_health = true
  }
  
  depends_on = [data.external.get_lb_arn]
}

# 백엔드 ECR 접근을 위한 이미지 풀 시크릿 생성
resource "kubernetes_secret" "backend_ecr_auth" {
  metadata {
    name      = "backend-ecr-auth"
    namespace = kubernetes_namespace.backend.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${aws_ecr_repository.backend_repo.repository_url}" = {
          auth = base64encode("AWS:${var.ecr_auth_token}")
        }
      }
    })
  }

  depends_on = [kubernetes_namespace.backend]
}

# 백엔드 네임스페이스 생성
resource "kubernetes_namespace" "backend" {
  metadata {
    name = var.backend_namespace
  }
}
