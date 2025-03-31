# 변수가 직접 입력되어야 하는 경우를 위한 변수 정의
# 원격 상태를 사용하면 대부분의 값이 자동으로 가져와지므로 많은 변수가 필요하지 않음

#---------------------------------------
# 입력 변수 정의
#---------------------------------------
variable "main_vpc_id" {
  description = "메인 VPC ID (원격 상태에서 가져올 수 없는 경우)"
  type        = string
  default     = null
}

variable "access_vpc_id" {
  description = "액세스 VPC ID (원격 상태에서 가져올 수 없는 경우)"
  type        = string
  default     = null
}

variable "main_vpc_cidr" {
  description = "메인 VPC CIDR 블록 (원격 상태에서 가져올 수 없는 경우)"
  type        = string
  default     = null
}

variable "access_vpc_cidr" {
  description = "액세스 VPC CIDR 블록 (원격 상태에서 가져올 수 없는 경우)"
  type        = string
  default     = null
}

# OpenVPN 관련 변수 추가 (11번에서 옮겨옴)
variable "key_name" {
  description = "OpenVPN 서버 접속용 키 페어 이름"
  type        = string
}

variable "admin_ip" {
  description = "OpenVPN 서버 관리를 위한 관리자 IP 주소"
  type        = string
} 