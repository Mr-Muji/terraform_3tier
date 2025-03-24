#---------------------------------------
# 데이터베이스 시크릿 변수
#---------------------------------------
variable "db_username" {
  description = "데이터베이스 사용자 이름"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "데이터베이스 비밀번호"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "데이터베이스 이름"
  type        = string
}