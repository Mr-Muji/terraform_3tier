/**
 * ECR 저장소 모듈
 * 
 * 이 모듈은 AWS ECR 저장소를 생성하고 관리합니다.
 * base-infra 단계에서 미리 생성하여 사용합니다.
 */

# ECR 저장소 생성
resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability
  
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  
  # 저장소 삭제 설정
  force_delete = var.force_delete
  
  # 태그 설정
  tags = merge(
    var.common_tags,
    {
      Name = var.repository_name
      Component = var.component_name
    },
    var.additional_tags
  )
  
  # 라이프사이클 설정
  lifecycle {
    # 태그 변경은 무시
    ignore_changes = [tags]
  }
}

# 이미지 수명 주기 정책 (옵션)
resource "aws_ecr_lifecycle_policy" "this" {
  count = var.enable_lifecycle_policy ? 1 : 0
  
  repository = aws_ecr_repository.this.name
  
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "최근 ${var.keep_image_count}개의 이미지만 유지",
        selection = {
          tagStatus     = "any",
          countType     = "imageCountMoreThan",
          countNumber   = var.keep_image_count
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# 리포지토리 정책 (옵션)
resource "aws_ecr_repository_policy" "this" {
  count = var.repository_policy != "" ? 1 : 0
  
  repository = aws_ecr_repository.this.name
  policy     = var.repository_policy
} 