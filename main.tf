# 네트워킹 모듈 호출
module "networking" {
  source = "./modules/networking"

  # 기본 변수 전달
  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  nat_subnet_cidrs    = var.nat_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
}

# 향후 다른 모듈 호출 예정
# module "security" { ... }
# module "compute" { ... }
# module "database" { ... }