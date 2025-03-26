# # Jenkins 플러그인 설정을 위한 ConfigMap
# # 이 파일은 Jenkins에 설치할 플러그인 목록을 정의합니다
# resource "kubernetes_config_map" "jenkins_plugins" {
#   metadata {
#     name      = "jenkins-plugins"                             # ConfigMap 이름
#     namespace = kubernetes_namespace.jenkins.metadata[0].name # Jenkins 네임스페이스
#   }

#   data = {
#     # plugins.txt 파일에는 설치할 플러그인 목록이 포함됨
#     # 형식은 '플러그인:버전' 형태
#     "plugins.txt" = <<-EOT
# configuration-as-code:1569.vb_72405b_80249
# kubernetes:3900.va_dce992317b_4
# workflow-aggregator:596.v8c21c963d92d
# git:5.1.0
# github:1.37.1
# aws-credentials:191.vcb_f183ce58b_9
# docker-workflow:563.vd5d2e5c4007f
# job-dsl:1.81
# credentials-binding:523.vd859a_4b_122e6
# pipeline-aws:1.44
# pipeline-stage-view:2.33
# parameterized-trigger:2.43.1
# matrix-auth:3.1.8
# antisamy-markup-formatter:2.7
# cloudbees-folder:6.858.v898218f3609d
#     EOT
#   }
# }
