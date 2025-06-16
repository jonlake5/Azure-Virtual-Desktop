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
| [azurerm_monitor_diagnostic_setting.diagnostic_setting](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_virtual_desktop_host_pool.avd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_host_pool) | resource |
| [azurerm_virtual_desktop_scaling_plan.weekdays](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_scaling_plan) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_rdp_properties"></a> [custom\_rdp\_properties](#input\_custom\_rdp\_properties) | n/a | `string` | n/a | yes |
| <a name="input_host_pool_friendly_name"></a> [host\_pool\_friendly\_name](#input\_host\_pool\_friendly\_name) | Friendly name of the host pool | `string` | n/a | yes |
| <a name="input_host_pool_name"></a> [host\_pool\_name](#input\_host\_pool\_name) | Name of the hostpool | `string` | n/a | yes |
| <a name="input_host_pool_type"></a> [host\_pool\_type](#input\_host\_pool\_type) | Type of host pool (personal or pooled) | `string` | n/a | yes |
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | Type of load balancing of user sessions on the host pool | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location of the host pool | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The Log Analytics workspace to send the diagnostic data to | `string` | n/a | yes |
| <a name="input_maximum_sessions_allowed"></a> [maximum\_sessions\_allowed](#input\_maximum\_sessions\_allowed) | Number of sessions per host | `number` | `1` | no |
| <a name="input_personal_desktop_assignment_type"></a> [personal\_desktop\_assignment\_type](#input\_personal\_desktop\_assignment\_type) | Automatic assignment – The service will select an available host and assign it to an user. Possible values are Automatic and Direct. Direct Assignment – Admin selects a specific host to assign to an user. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_preferred_app_group_type"></a> [preferred\_app\_group\_type](#input\_preferred\_app\_group\_type) | Option to specify the preferred Application Group type for the Virtual Desktop Host Pool | `string` | `"Desktop"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of resource group for the host pool | `string` | n/a | yes |
| <a name="input_scaling_plan_enabled"></a> [scaling\_plan\_enabled](#input\_scaling\_plan\_enabled) | Defines whether or not the scaling plan is enabled | `bool` | n/a | yes |
| <a name="input_scaling_plan_name"></a> [scaling\_plan\_name](#input\_scaling\_plan\_name) | Name of the host pool scaling plan | `string` | n/a | yes |
| <a name="input_scaling_plan_schedule"></a> [scaling\_plan\_schedule](#input\_scaling\_plan\_schedule) | n/a | <pre>object({<br/>    name                                 = string<br/>    days_of_week                         = list(string)<br/>    ramp_up_start_time                   = string<br/>    ramp_up_load_balancing_algorithm     = string<br/>    ramp_up_minimum_hosts_percent        = number<br/>    ramp_up_capacity_threshold_percent   = number<br/>    peak_start_time                      = string<br/>    peak_load_balancing_algorithm        = string<br/>    ramp_down_start_time                 = string<br/>    ramp_down_load_balancing_algorithm   = string<br/>    ramp_down_minimum_hosts_percent      = number<br/>    ramp_down_force_logoff_users         = bool<br/>    ramp_down_wait_time_minutes          = number<br/>    ramp_down_notification_message       = string<br/>    ramp_down_capacity_threshold_percent = number<br/>    ramp_down_stop_hosts_when            = string<br/>    off_peak_start_time                  = string<br/>    off_peak_load_balancing_algorithm    = string<br/>  })</pre> | n/a | yes |
| <a name="input_scaling_plan_time_zone"></a> [scaling\_plan\_time\_zone](#input\_scaling\_plan\_time\_zone) | Timezone of the scaling plan | `string` | n/a | yes |
| <a name="input_scheduled_agent_updates"></a> [scheduled\_agent\_updates](#input\_scheduled\_agent\_updates) | Whether or not to enable scheduled updates of the AVD agent | `bool` | `false` | no |
| <a name="input_scheduled_agent_updates_day_of_week"></a> [scheduled\_agent\_updates\_day\_of\_week](#input\_scheduled\_agent\_updates\_day\_of\_week) | Day of week to have scheduled agent updates enabled | `string` | `"Sunday"` | no |
| <a name="input_scheduled_agent_updates_hour_of_day"></a> [scheduled\_agent\_updates\_hour\_of\_day](#input\_scheduled\_agent\_updates\_hour\_of\_day) | Hour of day to schedule the agent updates | `number` | `0` | no |
| <a name="input_start_vm_on_connect"></a> [start\_vm\_on\_connect](#input\_start\_vm\_on\_connect) | Whether to start VM on connect or not | `bool` | `false` | no |
| <a name="input_validate_environment"></a> [validate\_environment](#input\_validate\_environment) | Whether or not to validate the environment | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hostpool_id"></a> [hostpool\_id](#output\_hostpool\_id) | n/a |
<!-- END_TF_DOCS -->