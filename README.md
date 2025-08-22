<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~>2.4.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 3.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.26.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.4.2 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~>0.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.3.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.26.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_application_group"></a> [application\_group](#module\_application\_group) | ./modules/application_group | n/a |
| <a name="module_automation"></a> [automation](#module\_automation) | github.com/jonlake5/Azure-Virtual-Desktop//modules/automation/ | 1.0.0 |
| <a name="module_host_pool"></a> [host\_pool](#module\_host\_pool) | ./modules/host_pool | n/a |
| <a name="module_managed_identity"></a> [managed\_identity](#module\_managed\_identity) | github.com/jonlake5/Azure-Virtual-Desktop//modules/managed_identity/ | 1.0.0 |
| <a name="module_monitoring"></a> [monitoring](#module\_monitoring) | github.com/jonlake5/Azure-Virtual-Desktop//modules/monitoring/ | 1.0.0 |
| <a name="module_policies"></a> [policies](#module\_policies) | ./modules/policies | n/a |
| <a name="module_role_assignments"></a> [role\_assignments](#module\_role\_assignments) | ./modules/avd_role_assignments | n/a |
| <a name="module_shared_image"></a> [shared\_image](#module\_shared\_image) | ./modules/image | n/a |
| <a name="module_shared_image_gallery"></a> [shared\_image\_gallery](#module\_shared\_image\_gallery) | ./modules/image_gallery | n/a |
| <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account) | ./modules/storage_account | n/a |
| <a name="module_updates"></a> [updates](#module\_updates) | ./modules/vm_updates | n/a |
| <a name="module_workspace"></a> [workspace](#module\_workspace) | ./modules/avd_workspace | n/a |

## Resources

| Name | Type |
|------|------|
| [azuread_group.avd_hosts](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azurerm_private_dns_a_record.storage_pe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_zone.file](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.file](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_resource_group.avd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.avd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.avd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.from_hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.to_hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action_group"></a> [action\_group](#input\_action\_group) | Defines an action group for sending alert emails to | <pre>object({<br/>    name       = string<br/>    short_name = string<br/>    email_receivers = list(object({<br/>      name                    = string<br/>      email_address           = string<br/>      use_common_alert_schema = optional(bool, true)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_automation_account_name"></a> [automation\_account\_name](#input\_automation\_account\_name) | Name of the automation account | `string` | `"AVD-Automation"` | no |
| <a name="input_automation_account_sku"></a> [automation\_account\_sku](#input\_automation\_account\_sku) | SKU of the automation account | `string` | `"Basic"` | no |
| <a name="input_automation_runbooks"></a> [automation\_runbooks](#input\_automation\_runbooks) | n/a | <pre>map(object({<br/>    file_name = string<br/>    webhook   = bool<br/>    type      = string<br/>    enabled   = optional(bool, true)<br/>  }))</pre> | n/a | yes |
| <a name="input_domain_join_password"></a> [domain\_join\_password](#input\_domain\_join\_password) | Password used to join AVD hosts to the domain. This will be populated into an azure keyvault for Azure Automation | `string` | `null` | no |
| <a name="input_dynamic_host_groups"></a> [dynamic\_host\_groups](#input\_dynamic\_host\_groups) | Objects that will be used to create Entra Dynamic Host Groups | <pre>map(object({<br/>    groupName            = string<br/>    groupFilterSubstring = string<br/>  }))</pre> | `{}` | no |
| <a name="input_environments"></a> [environments](#input\_environments) | n/a | <pre>map(object({<br/>    workspace = object({<br/>      workspace_description   = string<br/>      workspace_name          = string<br/>      workspace_friendly_name = string<br/>    })<br/>    host_pools = map(object({<br/>      auth_type                           = string<br/>      custom_rdp_properties               = optional(string, "enablecredsspsupport:i:1;videoplaybackmode:i:1;audiomode:i:0;devicestoredirect:s:*;drivestoredirect:s:*;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;redirectwebauthn:i:1;usbdevicestoredirect:s:*;use multimon:i:1;")<br/>      load_balancer_type                  = string<br/>      host_pool_friendly_name             = string<br/>      host_pool_name                      = string<br/>      host_pool_type                      = string<br/>      maximum_sessions_allowed            = optional(number, 999999)<br/>      personal_desktop_assignment_type    = optional(string, null)<br/>      preferred_app_group_type            = optional(string, "Desktop")<br/>      scaling_plan_enabled                = bool<br/>      scaling_plan_name                   = optional(string)<br/>      scaling_plan_time_zone              = optional(string)<br/>      scheduled_agent_updates             = optional(bool, false)<br/>      scheduled_agent_updates_hour_of_day = optional(number, 0)<br/>      scheduled_agent_updates_day_of_week = optional(string, "Sunday")<br/>      scaling_plan_schedule = optional(object({<br/>        name                                 = string<br/>        days_of_week                         = list(string)<br/>        ramp_up_start_time                   = string<br/>        ramp_up_load_balancing_algorithm     = string<br/>        ramp_up_minimum_hosts_percent        = number<br/>        ramp_up_capacity_threshold_percent   = number<br/>        peak_start_time                      = string<br/>        peak_load_balancing_algorithm        = string<br/>        ramp_down_start_time                 = string<br/>        ramp_down_load_balancing_algorithm   = string<br/>        ramp_down_minimum_hosts_percent      = number<br/>        ramp_down_force_logoff_users         = bool<br/>        ramp_down_wait_time_minutes          = number<br/>        ramp_down_notification_message       = string<br/>        ramp_down_capacity_threshold_percent = number<br/>        ramp_down_stop_hosts_when            = string<br/>        off_peak_start_time                  = string<br/>        off_peak_load_balancing_algorithm    = string<br/>      }))<br/>      start_vm_on_connect = optional(bool, false)<br/>      application_groups = optional(map(object({<br/>        application_group_assignnment_group_name = string<br/>        application_group_friendly_name          = optional(string, null)<br/>        application_group_name                   = string<br/>        application_group_type                   = string<br/>        default_desktop_display_name             = optional(string, null)<br/>        applications = optional(map(object({<br/>          friendly_name                = optional(string, null)<br/>          name                         = string<br/>          path                         = optional(string, null)<br/>          command_line_argument_policy = optional(string, null)<br/>          command_line_arguments       = optional(string, null)<br/>          icon_path                    = optional(string, null)<br/>          icon_index                   = optional(string, null)<br/>        })))<br/>      })))<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_images"></a> [images](#input\_images) | n/a | <pre>map(object({<br/>    shared_image_name      = string<br/>    shared_image_sku       = optional(string, null)<br/>    shared_image_offer     = optional(string, null)<br/>    shared_image_publisher = optional(string, null)<br/>  }))</pre> | n/a | yes |
| <a name="input_keyvault"></a> [keyvault](#input\_keyvault) | Map of object representing the keyvault to be created | <pre>map(object({<br/>    name        = string<br/>    secret_name = optional(string, "domain-join-password")<br/>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region that all the reources will be placed in | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | Name of the log analytics workspace to be created | `string` | `"law-avd"` | no |
| <a name="input_maintenance_definition"></a> [maintenance\_definition](#input\_maintenance\_definition) | n/a | <pre>map(object({<br/>    maintenance_name                 = string<br/>    maintenance_scope                = string<br/>    maintenance_duration             = optional(string)<br/>    maintenance_start_date_time      = string<br/>    maintenance_end_date_time        = optional(string)<br/>    maintenance_recurrence           = optional(string)<br/>    maintenance_time_zone            = string<br/>    patch_classifications_to_include = optional(list(string), ["Critical", "Security", ])<br/>  }))</pre> | n/a | yes |
| <a name="input_managed_identity_name"></a> [managed\_identity\_name](#input\_managed\_identity\_name) | Name of managed identity to create. This will be granted contributor roles on the sub | `string` | `"avd-automation"` | no |
| <a name="input_policy_target_locations"></a> [policy\_target\_locations](#input\_policy\_target\_locations) | A list of locations to target for the policy assignments for VMs | `list(string)` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group to be created | `string` | n/a | yes |
| <a name="input_resource_group_name_compute"></a> [resource\_group\_name\_compute](#input\_resource\_group\_name\_compute) | Resource Group name for the compute components | `string` | `null` | no |
| <a name="input_resource_group_name_monitoring"></a> [resource\_group\_name\_monitoring](#input\_resource\_group\_name\_monitoring) | Reource Group name for the monitoring components | `string` | `null` | no |
| <a name="input_resource_group_name_network"></a> [resource\_group\_name\_network](#input\_resource\_group\_name\_network) | Resource Group name for the network components | `string` | `null` | no |
| <a name="input_resource_group_name_service_objects"></a> [resource\_group\_name\_service\_objects](#input\_resource\_group\_name\_service\_objects) | Resource Group name for the service objects | `string` | `null` | no |
| <a name="input_resource_group_name_storage"></a> [resource\_group\_name\_storage](#input\_resource\_group\_name\_storage) | Resource Group name for the storage | `string` | `null` | no |
| <a name="input_shared_image_gallery_name"></a> [shared\_image\_gallery\_name](#input\_shared\_image\_gallery\_name) | Name of the shared image gallery to be created | `string` | n/a | yes |
| <a name="input_storage_account"></a> [storage\_account](#input\_storage\_account) | n/a | <pre>object({<br/>    smb_contributor_group_name          = string<br/>    smb_elevated_contributor_group_name = string<br/>    storage_account_name                = string<br/>    storage_account_share = optional(map(object({<br/>      name  = string<br/>      quota = number<br/>    })), {})<br/>    directory_config = map(object({<br/>      directory_type = optional(string)<br/>      active_directory_config = object({<br/>        domain_guid         = optional(string)<br/>        domain_name         = optional(string)<br/>        domain_sid          = optional(string)<br/>        forest_name         = optional(string)<br/>        netbios_domain_name = optional(string)<br/>        storage_sid         = optional(string)<br/>      })<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Name of the subnet to be created | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription Id the resources will be placed in | `string` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant ID of azure account | `string` | n/a | yes |
| <a name="input_vnet_dns_servers"></a> [vnet\_dns\_servers](#input\_vnet\_dns\_servers) | DNS servers for vnet | `list(string)` | `[]` | no |
| <a name="input_vnet_ip_space"></a> [vnet\_ip\_space](#input\_vnet\_ip\_space) | IP Space for the vnet | `string` | n/a | yes |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | Name of the vNet to be created | `string` | n/a | yes |
| <a name="input_vnet_peerings"></a> [vnet\_peerings](#input\_vnet\_peerings) | A list of maps to peer the newly created avd vnet to | <pre>map(object({<br/>    name                    = string<br/>    hub_resource_group_name = optional(string)<br/>    hub_vnet_id             = string<br/>    hub_vnet_name           = string<br/>    hub = object({<br/>      allow_virtual_network   = optional(bool, true)<br/>      use_remote_gateways     = optional(bool, true)<br/>      allow_forwarded_traffic = optional(bool, true)<br/>      allow_gateway_transit   = optional(bool, true)<br/>    })<br/>    spoke = object({<br/>      allow_virtual_network   = optional(bool, true)<br/>      use_remote_gateways     = optional(bool, true)<br/>      allow_forwarded_traffic = optional(bool, true)<br/>      allow_gateway_transit   = optional(bool, true)<br/>    })<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_keyvault_and_secret"></a> [keyvault\_and\_secret](#output\_keyvault\_and\_secret) | n/a |
| <a name="output_maintenance_config_name"></a> [maintenance\_config\_name](#output\_maintenance\_config\_name) | n/a |
| <a name="output_managed_identity_account_id"></a> [managed\_identity\_account\_id](#output\_managed\_identity\_account\_id) | n/a |
| <a name="output_packer_variables"></a> [packer\_variables](#output\_packer\_variables) | n/a |
| <a name="output_webhook_uri"></a> [webhook\_uri](#output\_webhook\_uri) | n/a |
<!-- END_TF_DOCS -->