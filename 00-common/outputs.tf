output "project_name" {
  description = "프로젝트 이름"
  value       = local.project_name
}

output "environment" {
  description = "환경 (dev, prod 등)"
  value       = local.environment
}

output "aws_region" {
  description = "AWS 리전"
  value       = local.aws_region
}

output "common_tags" {
  description = "공통 리소스 태그"
  value       = local.common_tags
}

output "domain_name" {
  description = "도메인 이름"
  value       = local.domain_name
}

output "remote_state_bucket" {
  description = "원격 상태 저장소 버킷 이름"
  value       = local.remote_state_bucket
}

output "remote_state_region" {
  description = "원격 상태 저장소 리전"
  value       = local.remote_state_region
}
