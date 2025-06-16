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
| [azurerm_maintenance_configuration.patch_window](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/maintenance_configuration) | resource |
| [azurerm_policy_definition.vm_update_check_custom](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |
| [azurerm_resource_group_policy_assignment.check_updates](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.update_prereqs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Location of the resource group policy assignments and maintenance definition | `string` | n/a | yes |
| <a name="input_maintenance_definition"></a> [maintenance\_definition](#input\_maintenance\_definition) | n/a | <pre>map(object({<br/>    maintenance_name                 = string<br/>    maintenance_scope                = string<br/>    maintenance_duration             = optional(string)<br/>    maintenance_start_date_time      = string<br/>    maintenance_end_date_time        = optional(string)<br/>    maintenance_recurrence           = optional(string)<br/>    maintenance_time_zone            = string<br/>    patch_classifications_to_include = list(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_managed_identity_id"></a> [managed\_identity\_id](#input\_managed\_identity\_id) | Id of the managed identity used for policy assignments | `string` | n/a | yes |
| <a name="input_managed_identity_principal_id"></a> [managed\_identity\_principal\_id](#input\_managed\_identity\_principal\_id) | Principal ID of the managed identity that will run the remediations | `string` | n/a | yes |
| <a name="input_policy_target_locations"></a> [policy\_target\_locations](#input\_policy\_target\_locations) | A list of locations to target the policy assignments to | `list(string)` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | Resource Group Id to assign the policy scope to | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of resource group for the shared gallery | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_maintenance_config_name"></a> [maintenance\_config\_name](#output\_maintenance\_config\_name) | n/a |
<!-- END_TF_DOCS -->