#-------------------------------------------------------
# ArgoCD 설치 모듈
# EKS 클러스터에 ArgoCD를 설치하고 설정합니다.
#-------------------------------------------------------

# ArgoCD 네임스페이스 생성
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

# ArgoCD Helm 차트 설치
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    yamlencode({
      server = {
        extraArgs = ["--insecure"]
        
        # 클러스터 내부 서비스 타입 (인그레스를 사용하므로 ClusterIP로 변경)
        service = {
          type = "ClusterIP"
        }
        
        # 인그레스 설정 간소화
        ingress = {
          enabled = var.ingress_enabled
          hosts   = [var.ingress_host]
          
          # 기본 어노테이션만 적용
          annotations = var.ingress_annotations
          
          # 인그레스 클래스 지정
          ingressClassName = var.ingress_class
        }
      }
      
      # gRPC 서비스 설정 추가 (ArgoCD UI와 CLI 통신용)
      configs = {
        params = {
          "server.insecure" = true
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

# CRD 적용 대기
resource "time_sleep" "wait_for_crds" {
  depends_on = [helm_release.argocd]
  create_duration = "30s"
}

# 인그레스 생성 대기 및 로드밸런서 주소 가져오기
resource "time_sleep" "wait_for_ingress" {
  depends_on = [helm_release.argocd]
  create_duration = "30s"  # 인그레스가 완전히 생성될 때까지 대기
}

# ArgoCD 인그레스 정보 가져오기
data "kubernetes_ingress_v1" "argocd_ingress" {
  depends_on = [time_sleep.wait_for_ingress]
  metadata {
    name      = "argocd-server"
    namespace = var.argocd_namespace
  }
}

# Route53에 도메인 레코드 생성
resource "aws_route53_record" "argocd" {
  count = var.ingress_enabled && var.create_route53_record && !var.use_external_dns ? 1 : 0  # External DNS 사용 시 비활성화

  zone_id = var.zone_id
  name    = var.ingress_host
  type    = "CNAME"
  ttl     = 300

  # 인그레스에서 생성된 로드밸런서 주소 사용
  records = [data.kubernetes_ingress_v1.argocd_ingress.status.0.load_balancer.0.ingress.0.hostname]
}
