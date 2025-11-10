## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [yandex_vpc_network.this](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_network) | resource |
| [yandex_vpc_subnet.this](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr"></a> [cidr](#input\_cidr) | IPv4 CIDR block for subnet | `string` | n/a | yes |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | Name of the network | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | Availability zone for subnet | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | ID of the VPC network |
| <a name="output_subnet"></a> [subnet](#output\_subnet) | Information about the subnet |
