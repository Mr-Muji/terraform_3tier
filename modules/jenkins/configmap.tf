resource "kubernetes_config_map" "jenkins_config" {
  metadata {
    name      = "jenkins-config"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }

  data = {
    # jenkins.yaml 파일명 유지 (변경하지 않음)
    "jenkins.yaml" = templatefile("${path.module}/files/jenkins-config.yaml", {
      namespace = kubernetes_namespace.jenkins.metadata[0].name
      admin_password = local.admin_password
      backend_ecr_name = var.backend_ecr_name
      github_token = local.github_token
    })
  }
}

# 작업 ConfigMap을 별도로 생성
resource "kubernetes_config_map" "jenkins_jobs" {
  metadata {
    name      = "jenkins-jobs"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }

  data = {
    # jenkins-jobs.yaml 파일명을 유지
    "jenkins-jobs.yaml" = templatefile("${path.module}/files/jenkins-jobs.yaml", {
      backend_ecr_name    = var.backend_ecr_name
      backend_ecr_url     = var.backend_ecr_url
      backend_repo_url    = var.backend_repo_url
      backend_repo_branch = var.backend_repo_branch
      jenkins_job_suffix  = var.jenkins_job_suffix
      job_description     = var.job_description
      scm_poll_interval   = var.scm_poll_interval
    })
  }
}