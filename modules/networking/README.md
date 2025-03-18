## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_subnet_group.db_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_eip.eip_nat_azone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip.eip_nat_czone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.igw_tier3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.natgw_azone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_nat_gateway.natgw_czone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route_table.rt_nat_azone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.rt_nat_czone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.rt_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.rt_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.rta_nat_azone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.rta_nat_czone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.rta_private_azone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.rta_private_czone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.rta_public_azone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.rta_public_czone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.subnet_nat_azone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.subnet_nat_czone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.subnet_private_azone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.subnet_private_czone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.subnet_public_azone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.subnet_public_czone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.vpc_tier3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | 사용할 가용 영역 목록 | `list(string)` | n/a | yes |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | VPC에서 DNS 호스트 이름 활성화 여부 | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | VPC에서 DNS 지원 활성화 여부 | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | 배포 환경 (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_nat_subnet_cidrs"></a> [nat\_subnet\_cidrs](#input\_nat\_subnet\_cidrs) | NAT 서브넷 CIDR 블록 맵 | `map(string)` | n/a | yes |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | 프라이빗 서브넷 CIDR 블록 맵 | `map(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | 프로젝트 이름 | `string` | n/a | yes |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | 퍼블릭 서브넷 CIDR 블록 맵 | `map(string)` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR 블록 | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_subnet_group_id"></a> [db\_subnet\_group\_id](#output\_db\_subnet\_group\_id) | 데이터베이스 서브넷 그룹 ID |
| <a name="output_db_subnet_group_name"></a> [db\_subnet\_group\_name](#output\_db\_subnet\_group\_name) | 데이터베이스 서브넷 그룹 이름 |
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | 인터넷 게이트웨이 ID |
| <a name="output_nat_gateway_a_id"></a> [nat\_gateway\_a\_id](#output\_nat\_gateway\_a\_id) | NAT 게이트웨이 A ID |
| <a name="output_nat_gateway_c_id"></a> [nat\_gateway\_c\_id](#output\_nat\_gateway\_c\_id) | NAT 게이트웨이 C ID |
| <a name="output_nat_route_table_a_id"></a> [nat\_route\_table\_a\_id](#output\_nat\_route\_table\_a\_id) | NAT 라우팅 테이블 A ID |
| <a name="output_nat_route_table_c_id"></a> [nat\_route\_table\_c\_id](#output\_nat\_route\_table\_c\_id) | NAT 라우팅 테이블 C ID |
| <a name="output_nat_subnet_a_id"></a> [nat\_subnet\_a\_id](#output\_nat\_subnet\_a\_id) | NAT 서브넷 A ID |
| <a name="output_nat_subnet_c_id"></a> [nat\_subnet\_c\_id](#output\_nat\_subnet\_c\_id) | NAT 서브넷 C ID |
| <a name="output_nat_subnet_ids"></a> [nat\_subnet\_ids](#output\_nat\_subnet\_ids) | NAT 서브넷 ID 목록 |
| <a name="output_private_route_table_id"></a> [private\_route\_table\_id](#output\_private\_route\_table\_id) | 프라이빗 라우팅 테이블 ID |
| <a name="output_private_subnet_a_id"></a> [private\_subnet\_a\_id](#output\_private\_subnet\_a\_id) | 프라이빗 서브넷 A ID |
| <a name="output_private_subnet_c_id"></a> [private\_subnet\_c\_id](#output\_private\_subnet\_c\_id) | 프라이빗 서브넷 C ID |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | 프라이빗 서브넷 ID 목록 |
| <a name="output_public_route_table_id"></a> [public\_route\_table\_id](#output\_public\_route\_table\_id) | 퍼블릭 라우팅 테이블 ID |
| <a name="output_public_subnet_a_id"></a> [public\_subnet\_a\_id](#output\_public\_subnet\_a\_id) | 퍼블릭 서브넷 A ID |
| <a name="output_public_subnet_c_id"></a> [public\_subnet\_c\_id](#output\_public\_subnet\_c\_id) | 퍼블릭 서브넷 C ID |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | 퍼블릭 서브넷 ID 목록 |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | VPC의 CIDR 블록 |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | 생성된 VPC의 ID |
