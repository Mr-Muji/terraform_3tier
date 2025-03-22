<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.91.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_compute"></a> [compute](#module\_compute) | ./modules/compute | n/a |
| <a name="module_frontend"></a> [frontend](#module\_frontend) | ./modules/frontend | n/a |
| <a name="module_networking"></a> [networking](#module\_networking) | ./modules/networking | n/a |
| <a name="module_security"></a> [security](#module\_security) | ./modules/security | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_route53_zone.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | 사용할 가용 영역 목록 | `list(string)` | <pre>[<br/>  "ap-northeast-2a",<br/>  "ap-northeast-2c"<br/>]</pre> | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS 리전 | `string` | `"ap-northeast-2"` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | 모든 리소스에 적용할 공통 태그 | `map(string)` | `{}` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | EKS 클러스터 이름 | `string` | `"eks-cluster"` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | VPC에서 DNS 호스트 이름 활성화 여부 | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | VPC에서 DNS 지원 활성화 여부 | `bool` | `true` | no |
| <a name="input_enabled_cluster_log_types"></a> [enabled\_cluster\_log\_types](#input\_enabled\_cluster\_log\_types) | EKS 클러스터에서 활성화할 로그 유형 | `list(string)` | <pre>[<br/>  "api",<br/>  "audit"<br/>]</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | 배포 환경 | `string` | `"dev"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | EKS 클러스터에 사용할 쿠버네티스 버전 | `string` | `"1.31"` | no |
| <a name="input_nat_subnet_cidrs"></a> [nat\_subnet\_cidrs](#input\_nat\_subnet\_cidrs) | NAT 서브넷 CIDR 블록 맵 | `map(string)` | <pre>{<br/>  "Azone": "10.0.10.0/24",<br/>  "Czone": "10.0.20.0/24"<br/>}</pre> | no |
| <a name="input_node_capacity_type"></a> [node\_capacity\_type](#input\_node\_capacity\_type) | EKS 노드 용량 타입 (ON\_DEMAND 또는 SPOT) | `string` | `"ON_DEMAND"` | no |
| <a name="input_node_desired_size"></a> [node\_desired\_size](#input\_node\_desired\_size) | EKS 노드 그룹의 원하는 노드 수 | `number` | `2` | no |
| <a name="input_node_disk_size"></a> [node\_disk\_size](#input\_node\_disk\_size) | EKS 노드의 디스크 크기(GB) | `number` | `20` | no |
| <a name="input_node_instance_types"></a> [node\_instance\_types](#input\_node\_instance\_types) | EKS 노드 그룹에 사용할 인스턴스 타입 목록 | `list(string)` | <pre>[<br/>  "t3.medium"<br/>]</pre> | no |
| <a name="input_node_max_size"></a> [node\_max\_size](#input\_node\_max\_size) | EKS 노드 그룹의 최대 노드 수 | `number` | `5` | no |
| <a name="input_node_min_size"></a> [node\_min\_size](#input\_node\_min\_size) | EKS 노드 그룹의 최소 노드 수 | `number` | `1` | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | 프라이빗 서브넷 CIDR 블록 맵 | `map(string)` | <pre>{<br/>  "Azone": "10.0.100.0/24",<br/>  "Czone": "10.0.200.0/24"<br/>}</pre> | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | 프로젝트 이름 | `string` | `"tier3"` | no |
| <a name="input_public_access_cidrs"></a> [public\_access\_cidrs](#input\_public\_access\_cidrs) | EKS API 서버에 공개적으로 접근할 수 있는 CIDR 블록 | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | 퍼블릭 서브넷 CIDR 블록 맵 | `map(string)` | <pre>{<br/>  "Azone": "10.0.1.0/24",<br/>  "Czone": "10.0.2.0/24"<br/>}</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR 블록 | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_security_group_id"></a> [app\_security\_group\_id](#output\_app\_security\_group\_id) | 애플리케이션 티어 보안 그룹 ID - 외부에서 참조하거나 문서화에 사용됩니다 |
| <a name="output_db_security_group_id"></a> [db\_security\_group\_id](#output\_db\_security\_group\_id) | 데이터베이스 티어 보안 그룹 ID - 외부에서 참조하거나 문서화에 사용됩니다 |
| <a name="output_eks_cluster_certificate_authority_data"></a> [eks\_cluster\_certificate\_authority\_data](#output\_eks\_cluster\_certificate\_authority\_data) | 클러스터 인증 기관 인증서 데이터 |
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | 쿠버네티스 API 서버 엔드포인트 |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | EKS 클러스터 ID |
| <a name="output_frontend_cloudfront_distribution_id"></a> [frontend\_cloudfront\_distribution\_id](#output\_frontend\_cloudfront\_distribution\_id) | 프론트엔드 CloudFront 배포 ID |
| <a name="output_frontend_cloudfront_domain"></a> [frontend\_cloudfront\_domain](#output\_frontend\_cloudfront\_domain) | 프론트엔드 CloudFront 도메인 |
| <a name="output_frontend_s3_bucket"></a> [frontend\_s3\_bucket](#output\_frontend\_s3\_bucket) | 프론트엔드 S3 버킷 이름 |
| <a name="output_nat_subnet_ids"></a> [nat\_subnet\_ids](#output\_nat\_subnet\_ids) | 생성된 NAT 서브넷 ID 목록 |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | 생성된 프라이빗 서브넷 ID 목록 |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | 생성된 퍼블릭 서브넷 ID 목록 |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | 생성된 VPC ID |
| <a name="output_web_security_group_id"></a> [web\_security\_group\_id](#output\_web\_security\_group\_id) | 웹 티어 보안 그룹 ID - 외부에서 참조하거나 문서화에 사용됩니다 |
<!-- END_TF_DOCS -->