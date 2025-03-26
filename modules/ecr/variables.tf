#-----------------------------------------
# ECR 모듈 변수
#-----------------------------------------

variable "repository_name" {
  description = "ECR 저장소 이름"
  type        = string
}

variable "component_name" {
  description = "컴포넌트 이름 (frontend, backend 등)"
  type        = string
  default     = "app"
}

variable "image_tag_mutability" {
  description = "이미지 태그 변경 가능 여부 (MUTABLE 또는 IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
  
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability는 'MUTABLE' 또는 'IMMUTABLE'이어야 합니다."
  }
}

variable "scan_on_push" {
  description = "이미지 푸시 시 취약점 스캔 여부"
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "저장소에 이미지가 있어도 강제 삭제할지 여부"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "모든 리소스에 적용할 공통 태그"
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "추가 태그"
  type        = map(string)
  default     = {}
}

variable "enable_lifecycle_policy" {
  description = "이미지 수명 주기 정책 활성화 여부"
  type        = bool
  default     = true
}

variable "keep_image_count" {
  description = "보관할 최근 이미지 수"
  type        = number
  default     = 10
}

variable "repository_policy" {
  description = "저장소 정책 (JSON 문자열)"
  type        = string
  default     = ""
} 