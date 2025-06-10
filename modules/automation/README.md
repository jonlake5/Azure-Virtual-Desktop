<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_automation_account.automation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account) | resource |
| [azurerm_automation_powershell72_module.module](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_powershell72_module) | resource |
| [azurerm_automation_runbook.runbook](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook) | resource |
| [azurerm_automation_variable_string.string](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_string) | resource |
| [azurerm_automation_webhook.webhook](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_webhook) | resource |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_role_assignment.managed_identity_read_write_key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.tf_read_write_key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_automation_account_name"></a> [automation\_account\_name](#input\_automation\_account\_name) | Name of the automation account | `string` | n/a | yes |
| <a name="input_automation_account_sku_name"></a> [automation\_account\_sku\_name](#input\_automation\_account\_sku\_name) | SKU of automation account | `string` | n/a | yes |
| <a name="input_automation_variables"></a> [automation\_variables](#input\_automation\_variables) | List of variables to apply to the automation account | `list(object({ key = string, value = string }))` | `[]` | no |
| <a name="input_domain_join_password"></a> [domain\_join\_password](#input\_domain\_join\_password) | Password used for domain join of the AVD hosts | `string` | n/a | yes |
| <a name="input_identity"></a> [identity](#input\_identity) | n/a | <pre>list(object({<br/>    identity_ids  = list(string)<br/>    identity_type = string<br/>  }))</pre> | n/a | yes |
| <a name="input_keyvault_name"></a> [keyvault\_name](#input\_keyvault\_name) | Name of keyvault used to store domain join password | `string` | n/a | yes |
| <a name="input_keyvault_secret_name"></a> [keyvault\_secret\_name](#input\_keyvault\_secret\_name) | Name of Key Vault secret that holds the domain join password | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_managed_identity_principal_id"></a> [managed\_identity\_principal\_id](#input\_managed\_identity\_principal\_id) | Principal ID of the Managed Identity used to access keyvault | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of resource group for the shared gallery | `string` | n/a | yes |
| <a name="input_runbooks"></a> [runbooks](#input\_runbooks) | Map of objects defining the runbook | <pre>map(object({<br/>    file_name = string<br/>    webhook   = bool<br/>    type      = string<br/>    enabled   = bool<br/>  }))</pre> | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant ID of Azure account | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_keyvault_name"></a> [keyvault\_name](#output\_keyvault\_name) | n/a |
| <a name="output_keyvault_secret"></a> [keyvault\_secret](#output\_keyvault\_secret) | n/a |
| <a name="output_webhook_url"></a> [webhook\_url](#output\_webhook\_url) | n/a |
<!-- END_TF_DOCS -->