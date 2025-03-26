# Jenkins 기본 설정을 위한 ConfigMap
# Jenkins Configuration as Code (JCasC)를 위한 설정 파일을 포함합니다
resource "kubernetes_config_map" "jenkins_config" {
  metadata {
    name      = "jenkins-config"  # ConfigMap 이름
    namespace = kubernetes_namespace.jenkins.metadata[0].name  # Jenkins 네임스페이스
  }

  data = {
    # 파일 이름 변경 - "jenkins.yaml"로 통일
    "jenkins.yaml" = templatefile("${path.module}/files/jenkins-config.yaml", {
      namespace = kubernetes_namespace.jenkins.metadata[0].name  # Jenkins 네임스페이스
      admin_password = local.admin_password  # 관리자 비밀번호 (secret.tf의 local 변수)
      backend_ecr_name = var.backend_ecr_name  # 백엔드 ECR 저장소 이름
      github_token = local.github_token  # 직접 변수가 아닌 locals에서 가져온 값 사용
    })
    
    # 작업 파일도 이름 변경
    "jobs.yaml" = templatefile("${path.module}/files/jenkins-jobs.yaml", {
      backend_ecr_name = var.backend_ecr_name
      backend_ecr_url = var.backend_ecr_url
      backend_repo_url = var.backend_repo_url
      backend_repo_branch = var.backend_repo_branch
      jenkins_job_suffix = var.jenkins_job_suffix
      job_description = var.job_description
      scm_poll_interval = var.scm_poll_interval
    })
  }
}