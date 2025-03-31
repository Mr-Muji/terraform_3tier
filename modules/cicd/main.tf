/**
 * CICD 모듈
 * 
 * 이 모듈은 다음 기능을 제공합니다:
 * 1. 기존 ECR 저장소 참조 (00-prerequisites에서 생성됨)
 * 2. ArgoCD Root Application - App of Apps 패턴 구현
 */

#-------------------------------------------------------
# 1. ECR 저장소 참조 (생성하지 않음)
#-------------------------------------------------------

# 모든 ECR 저장소 목록 조회
data "aws_ecr_repositories" "all" {}

# 프론트엔드 저장소는 조건부로 참조
data "aws_ecr_repository" "existing_frontend_repo" {
  count = var.enable_frontend_deployment && contains(data.aws_ecr_repositories.all.names, var.frontend_repo_name) ? 1 : 0
  name  = var.frontend_repo_name
}

data "aws_ecr_repository" "existing_backend_repo" {
  count = contains(data.aws_ecr_repositories.all.names, var.backend_repo_name) ? 1 : 0
  name  = var.backend_repo_name
}

#-------------------------------------------------------
# 2. ArgoCD App of Apps 설정
#-------------------------------------------------------

# ArgoCD 네임스페이스 참조
data "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

# 데이터베이스 자격 증명 정보 가져오기
data "aws_secretsmanager_secret" "db_credentials" {
  arn = var.db_credentials_secret_arn
}

data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = data.aws_secretsmanager_secret.db_credentials.id
}

locals {
  # Secret 값을 JSON으로 변환
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)
}

# App of Apps 루트 애플리케이션 생성
resource "kubernetes_manifest" "argocd_root_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "${var.prefix}-root-app"
      namespace = var.argocd_namespace
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      project = "default"
      
      source = {
        repoURL        = var.helm_charts_repo_url
        path           = var.helm_charts_repo_path
        targetRevision = var.helm_charts_revision
        
        # Helm 차트 값 설정
        helm = {
          values = yamlencode({
            global = {
              environment = var.environment
              domain      = var.domain_name
              
              # 이미지 저장소 정보 주입
              repositories = {
                frontend = var.frontend_repository_url
                backend = var.backend_repository_url
              }
              
              # 데이터베이스 연결 정보 추가
              database = {
                host     = var.db_host
                port     = var.db_port
                name     = var.db_name
                username = local.db_credentials.username
                password = local.db_credentials.password
              }
              
              # 하위 앱들에게 전달할 인그레스 설정
              ingress = {
                annotations = {
                  "kubernetes.io/ingress.class" = "alb"
                  "alb.ingress.kubernetes.io/scheme" = "internet-facing"
                  "alb.ingress.kubernetes.io/target-type" = "ip"
                  
                  # 로드밸런서 이름 지정
                  "alb.ingress.kubernetes.io/load-balancer-name" = var.frontend_lb_name
                  
                  # External DNS 어노테이션 추가
                  "external-dns.alpha.kubernetes.io/hostname" = var.domain_name
                }
                # hosts 섹션 주석 처리 - External DNS가 처리할 예정
                # hosts = {
                #   frontend = var.frontend_ingress_host
                # }
              }
            }
          })
        }
      }
      
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.argocd_namespace
      }
      
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

  depends_on = [data.kubernetes_namespace.argocd]
}

#-------------------------------------------------------
# 3. 프론트엔드 Route53 레코드 사전 생성
#-------------------------------------------------------

# 프론트엔드 서브도메인 레코드 - External DNS 사용을 위해 주석 처리
# resource "aws_route53_record" "frontend_record" {
#   count = var.zone_id != "" && var.enable_immediate_dns_setup ? 1 : 0
#   
#   zone_id = var.zone_id
#   name    = var.domain_name  # 또는 var.frontend_ingress_host
#   type    = "A"
#   
#   alias {
#     name                   = "${var.frontend_lb_name}.${var.region}.elb.amazonaws.com"
#     zone_id                = var.alb_hosted_zone_id
#     evaluate_target_health = true
#   }
# }

# 루트 도메인 레코드 (선택 사항) - External DNS 사용을 위해 주석 처리
# resource "aws_route53_record" "root_domain_record" {
#   count = var.zone_id != "" && var.enable_immediate_dns_setup ? 1 : 0
#   
#   zone_id = var.zone_id
#   name    = var.domain_name
#   type    = "A"
#   
#   alias {
#     name                   = "${var.frontend_lb_name}.${var.region}.elb.amazonaws.com"
#     zone_id                = var.alb_hosted_zone_id
#     evaluate_target_health = true
#   }
#
#   # 오류 무시 옵션 추가
#   lifecycle {
#     ignore_changes = [alias]
#   }
# }

# 이 부분을 주석 처리하거나 제거하세요
# resource "aws_route53_record" "www_domain" {
#   count = var.zone_id != "" && var.enable_immediate_dns_setup ? 1 : 0
#   
#   zone_id = var.zone_id
#   name    = "www.${var.domain_name}"
#   type    = "CNAME"
#   ttl     = 60
#   records = ["${var.frontend_lb_name}.${var.region}.elb.amazonaws.com"]
# }
