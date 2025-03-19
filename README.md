<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_networking"></a> [networking](#module\_networking) | ./modules/networking | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | 사용할 가용 영역 목록 | `list(string)` | <pre>[<br/>  "ap-northeast-2a",<br/>  "ap-northeast-2c"<br/>]</pre> | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS 리전 | `string` | `"ap-northeast-2"` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | VPC에서 DNS 호스트 이름 활성화 여부 | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | VPC에서 DNS 지원 활성화 여부 | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | 배포 환경 | `string` | `"dev"` | no |
| <a name="input_nat_subnet_cidrs"></a> [nat\_subnet\_cidrs](#input\_nat\_subnet\_cidrs) | NAT 서브넷 CIDR 블록 맵 | `map(string)` | <pre>{<br/>  "Azone": "10.0.10.0/24",<br/>  "Czone": "10.0.20.0/24"<br/>}</pre> | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | 프라이빗 서브넷 CIDR 블록 맵 | `map(string)` | <pre>{<br/>  "Azone": "10.0.100.0/24",<br/>  "Czone": "10.0.200.0/24"<br/>}</pre> | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | 프로젝트 이름 | `string` | `"tier3"` | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | 퍼블릭 서브넷 CIDR 블록 맵 | `map(string)` | <pre>{<br/>  "Azone": "10.0.1.0/24",<br/>  "Czone": "10.0.2.0/24"<br/>}</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR 블록 | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nat_subnet_ids"></a> [nat\_subnet\_ids](#output\_nat\_subnet\_ids) | 생성된 NAT 서브넷 ID 목록 |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | 생성된 프라이빗 서브넷 ID 목록 |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | 생성된 퍼블릭 서브넷 ID 목록 |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | 생성된 VPC ID |
<!-- END_TF_DOCS -->