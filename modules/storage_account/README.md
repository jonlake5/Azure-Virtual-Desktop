<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_endpoint.file_storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.smb_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.smb_elevated_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.avd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_network_rules.avd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_share.FSXShare](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |
| [azuread_group.smb_contributor](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_group.smb_elevated_contributor](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azurerm_role_definition.smb_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/role_definition) | data source |
| [azurerm_role_definition.smb_elevated_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/role_definition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_directory_config"></a> [directory\_config](#input\_directory\_config) | n/a | <pre>map(object({<br/>    directory_type = optional(string)<br/>    active_directory_config = object({<br/>      domain_guid         = optional(string)<br/>      domain_name         = optional(string)<br/>      domain_sid          = optional(string)<br/>      forest_name         = optional(string)<br/>      netbios_domain_name = optional(string)<br/>      storage_sid         = optional(string)<br/>    })<br/>  }))</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location of the storage account | `string` | n/a | yes |
| <a name="input_pe_subnet_id"></a> [pe\_subnet\_id](#input\_pe\_subnet\_id) | Subnet id to put the private endpoint in for the file share | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of resource group for the shared gallery | `string` | n/a | yes |
| <a name="input_smb_contributor_group_name"></a> [smb\_contributor\_group\_name](#input\_smb\_contributor\_group\_name) | Name of group that will be assigned SMB Contributor role | `string` | n/a | yes |
| <a name="input_smb_elevated_contributor_group_name"></a> [smb\_elevated\_contributor\_group\_name](#input\_smb\_elevated\_contributor\_group\_name) | Name of group that will be assigned SMB Elevated Contributor role | `string` | n/a | yes |
| <a name="input_storage_account_kind"></a> [storage\_account\_kind](#input\_storage\_account\_kind) | Type of storage account, i.e. FileStorage | `string` | `"FileStorage"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the storage account to create | `string` | n/a | yes |
| <a name="input_storage_account_network_rules_default_action"></a> [storage\_account\_network\_rules\_default\_action](#input\_storage\_account\_network\_rules\_default\_action) | Default Action on storage network account | `string` | `"Deny"` | no |
| <a name="input_storage_account_public_network_access_enabled"></a> [storage\_account\_public\_network\_access\_enabled](#input\_storage\_account\_public\_network\_access\_enabled) | True enables public access, false disables | `bool` | `false` | no |
| <a name="input_storage_account_replication_type"></a> [storage\_account\_replication\_type](#input\_storage\_account\_replication\_type) | Replication type of storage account | `string` | `"LRS"` | no |
| <a name="input_storage_account_share"></a> [storage\_account\_share](#input\_storage\_account\_share) | n/a | <pre>map(object({<br/>    name  = string<br/>    quota = number<br/>  }))</pre> | n/a | yes |
| <a name="input_storage_account_tier"></a> [storage\_account\_tier](#input\_storage\_account\_tier) | Tier of storage account (Premium or General Purpose) | `string` | `"Premium"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_private_endpoint_ip_address"></a> [private\_endpoint\_ip\_address](#output\_private\_endpoint\_ip\_address) | n/a |
<!-- END_TF_DOCS -->