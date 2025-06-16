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
| [azurerm_log_analytics_workspace.workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_data_collection_rule.avd_session_hosts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) | resource |
| [azurerm_resource_group_policy_assignment.ama_install](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.associate_dcr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ama_install_policy_assignment_name"></a> [ama\_install\_policy\_assignment\_name](#input\_ama\_install\_policy\_assignment\_name) | n/a | `string` | `"Azure Monitoring Agent Policy"` | no |
| <a name="input_law_name"></a> [law\_name](#input\_law\_name) | Name of log analytics workspace | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location of the log analytics workspace | `string` | n/a | yes |
| <a name="input_managed_identity_id"></a> [managed\_identity\_id](#input\_managed\_identity\_id) | Managed Identity Id for policy remediation | `string` | n/a | yes |
| <a name="input_policy_assignment_resource_group_id"></a> [policy\_assignment\_resource\_group\_id](#input\_policy\_assignment\_resource\_group\_id) | Resource Group Id to assign the policy to | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of resource group for the log analytics workspace | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription Id to apply the contributore role of the managed identity | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | n/a |
<!-- END_TF_DOCS -->