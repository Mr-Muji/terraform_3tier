#-------------------------------------------------------
# ArgoCD 설치 모듈
# EKS 클러스터에 ArgoCD를 설치하고 설정합니다.
#-------------------------------------------------------

# 클러스터가 준비되었는지 확인하는 리소스
resource "null_resource" "wait_for_cluster" {
  count = var.cluster_exists ? 1 : 0

  # EKS 클러스터 ID가 설정되어 있을 때만 실행
  provisioner "local-exec" {
    command = <<-EOT
      echo "EKS 클러스터 연결 확인 중..."
      aws eks describe-cluster --name ${var.eks_cluster_id} --region ${var.region} --query 'cluster.status' --output text | grep -q ACTIVE
      echo "EKS 클러스터가 준비되었습니다."
    EOT
  }
}

# ArgoCD 네임스페이스 생성
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
    
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  depends_on = [null_resource.wait_for_cluster]
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
        service = {
          type = "NodePort"
        }
        ingress = {
          enabled = var.ingress_enabled
          hosts   = [var.ingress_host]
          annotations = merge(var.ingress_annotations, {
            "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
            "alb.ingress.kubernetes.io/ssl-redirect" = "false"
            "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
          })
          ingressClassName = var.ingress_class
        }
      }
      # 비밀번호 설정 주석 처리
    #   configs = {
    #     secret = {
    #       argocdServerAdminPassword = var.argocd_admin_password_hash
    #     }
    #   }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

# CRD 적용 대기
resource "time_sleep" "wait_for_crds" {
  depends_on = [helm_release.argocd]
  create_duration = "30s"
}

# ArgoCD 인그레스 데이터 소스
data "kubernetes_ingress_v1" "argocd_ingress" {
  count = var.ingress_enabled ? 1 : 0
  
  depends_on = [helm_release.argocd, time_sleep.wait_for_crds]
  
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
}

# 인그레스가 완전히 프로비저닝될 때까지 대기
resource "time_sleep" "wait_for_ingress" {
  count = var.ingress_enabled ? 1 : 0
  
  depends_on = [data.kubernetes_ingress_v1.argocd_ingress]
  create_duration = "30s"
}

# 로드 밸런서 정보를 직접 가져오는 데이터 소스
data "external" "get_argocd_lb_arn" {
  count = var.ingress_enabled && var.zone_id != "" ? 1 : 0
  
  program = ["bash", "-c", <<-EOT
    LB_NAME=$(kubectl get ingress -n ${kubernetes_namespace.argocd.metadata[0].name} argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' | cut -d'.' -f1 | cut -d'-' -f1)
    LB_ARN=$(aws elbv2 describe-load-balancers --region ${var.region} --names $LB_NAME --query 'LoadBalancers[0].LoadBalancerArn' --output text)
    DNS_NAME=$(aws elbv2 describe-load-balancers --region ${var.region} --names $LB_NAME --query 'LoadBalancers[0].DNSName' --output text)
    ZONE_ID=$(aws elbv2 describe-load-balancers --region ${var.region} --names $LB_NAME --query 'LoadBalancers[0].CanonicalHostedZoneId' --output text)
    echo "{\"arn\":\"$LB_ARN\",\"dns_name\":\"$DNS_NAME\",\"zone_id\":\"$ZONE_ID\"}"
  EOT
  ]
  
  depends_on = [data.kubernetes_ingress_v1.argocd_ingress, time_sleep.wait_for_ingress]
}

# Route 53 레코드 수정
resource "aws_route53_record" "argocd" {
  count = var.ingress_enabled && var.zone_id != "" && length(data.external.get_argocd_lb_arn) > 0 ? 1 : 0
  
  zone_id = var.zone_id
  name    = var.ingress_host
  type    = "A"
  
  alias {
    name                   = data.external.get_argocd_lb_arn[0].result.dns_name
    zone_id                = data.external.get_argocd_lb_arn[0].result.zone_id
    evaluate_target_health = true
  }
  
  depends_on = [data.external.get_argocd_lb_arn]
}