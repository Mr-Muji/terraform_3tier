# Jenkins 초기 작업 설정을 위한 ConfigMap
# 이 파일은 Jenkins가 시작될 때 기본 작업(Job)을 생성하는 설정을 포함합니다
resource "kubernetes_config_map" "jenkins_jobs" {
  metadata {
    name      = "jenkins-jobs"  # ConfigMap 이름
    namespace = kubernetes_namespace.jenkins.metadata[0].name  # Jenkins 네임스페이스
  }

  data = {
    # jenkins-jobs.yaml 템플릿을 사용하여 작업 정의 생성
    # Jenkins Job DSL 플러그인이 이 파일을 읽어 작업을 자동 생성
    "jenkins-jobs.yaml" = templatefile("${path.module}/files/jenkins-jobs.yaml", {
      backend_ecr_name    = var.backend_ecr_name     # 백엔드 ECR 저장소 이름
      backend_ecr_url     = var.backend_ecr_url      # 백엔드 ECR URL
      backend_repo_url    = var.backend_repo_url     # 백엔드 Git 저장소 URL
      backend_repo_org    = var.backend_repo_org     # 백엔드 GitHub 조직
      backend_repo_branch = var.backend_repo_branch  # 백엔드 Git 브랜치
      jenkins_job_suffix  = var.jenkins_job_suffix   # 작업 이름 접미사
      job_description     = var.job_description      # 작업 설명
      scm_poll_interval   = var.scm_poll_interval    # Git 폴링 간격
    })
  }
}