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
| [azurerm_role_assignment.application_group_dv_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_virtual_desktop_application.application](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_application) | resource |
| [azurerm_virtual_desktop_application_group.application_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_application_group) | resource |
| [azurerm_virtual_desktop_workspace_application_group_association.ws_ag_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_workspace_application_group_association) | resource |
| [azuread_group.assignment_group](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_group_assignnment_group_name"></a> [application\_group\_assignnment\_group\_name](#input\_application\_group\_assignnment\_group\_name) | Name of Entra Group that will be provided access to this application group | `string` | n/a | yes |
| <a name="input_application_group_friendly_name"></a> [application\_group\_friendly\_name](#input\_application\_group\_friendly\_name) | Friendly name of the application group | `string` | `null` | no |
| <a name="input_application_group_name"></a> [application\_group\_name](#input\_application\_group\_name) | Name of the Application Group | `string` | n/a | yes |
| <a name="input_application_group_type"></a> [application\_group\_type](#input\_application\_group\_type) | Type of application group. Allowed Values are "RemoteApp" and "Desktop" | `string` | n/a | yes |
| <a name="input_applications"></a> [applications](#input\_applications) | A map of objects outlining applications to be published in the application group | <pre>map(object({<br/>    name                         = string<br/>    friendly_name                = string<br/>    path                         = string<br/>    command_line_argument_policy = optional(string, "DoNotAllow")<br/>    command_line_arguments       = optional(string, null)<br/>    icon_path                    = optional(string, null)<br/>    icon_index                   = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_host_pool_id"></a> [host\_pool\_id](#input\_host\_pool\_id) | Host Pool ID to associate this application group with | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location of the application group | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of resource group for the application group | `string` | n/a | yes |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | Workspace ID to associate this application group with | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->