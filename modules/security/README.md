<!-- BEGIN_TF_DOCS -->
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
| [aws_iam_role.eks_cluster_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_node_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecr_read_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_cluster_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_cni_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_service_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_worker_node_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.app_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.db_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.web_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | EKS 클러스터 이름 - 클러스터 관련 리소스 식별에 사용됩니다 | `string` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | 배포 환경 (dev, staging, prod) - 리소스 태그 지정에 사용됩니다 | `string` | n/a | yes |
| <a name="input_nat_subnet_ids"></a> [nat\_subnet\_ids](#input\_nat\_subnet\_ids) | NAT 서브넷 ID 목록 - 애플리케이션 리소스 배포에 사용됩니다 | `list(string)` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | 프라이빗 서브넷 ID 목록 - 데이터베이스 및 내부 리소스 배포에 사용됩니다 | `list(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | 프로젝트 이름 - 모든 리소스 이름의 접두사로 사용됩니다 | `string` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | 퍼블릭 서브넷 ID 목록 - ALB 및 외부 리소스 배포에 사용됩니다 | `list(string)` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR 블록 - 내부 통신 규칙 정의에 사용될 수 있습니다 | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | 보안 그룹이 생성될 VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_security_group_id"></a> [app\_security\_group\_id](#output\_app\_security\_group\_id) | 애플리케이션 티어 보안 그룹 ID - EKS 노드 및 애플리케이션 서버에 연결하는 데 사용됩니다 |
| <a name="output_cache_security_group_id"></a> [cache\_security\_group\_id](#output\_cache\_security\_group\_id) | 캐시 서비스 보안 그룹 ID - Redis 및 ElastiCache에 연결하는 데 사용됩니다 |
| <a name="output_db_security_group_id"></a> [db\_security\_group\_id](#output\_db\_security\_group\_id) | 데이터베이스 티어 보안 그룹 ID - RDS 및 기타 데이터베이스 서비스에 연결하는 데 사용됩니다 |
| <a name="output_eks_cluster_role_arn"></a> [eks\_cluster\_role\_arn](#output\_eks\_cluster\_role\_arn) | EKS 클러스터 IAM 역할 ARN - EKS 클러스터 생성 시 사용됩니다 |
| <a name="output_eks_cluster_role_name"></a> [eks\_cluster\_role\_name](#output\_eks\_cluster\_role\_name) | EKS 클러스터 IAM 역할 이름 - 추가 정책 연결 시 참조됩니다 |
| <a name="output_eks_node_role_arn"></a> [eks\_node\_role\_arn](#output\_eks\_node\_role\_arn) | EKS 노드 그룹 IAM 역할 ARN - EKS 노드 그룹 생성 시 사용됩니다 |
| <a name="output_eks_node_role_name"></a> [eks\_node\_role\_name](#output\_eks\_node\_role\_name) | EKS 노드 그룹 IAM 역할 이름 - 추가 정책 연결 시 참조됩니다 |
| <a name="output_web_security_group_id"></a> [web\_security\_group\_id](#output\_web\_security\_group\_id) | 웹 티어 보안 그룹 ID - ALB 및 웹 서버에 연결하는 데 사용됩니다 |
<!-- END_TF_DOCS -->