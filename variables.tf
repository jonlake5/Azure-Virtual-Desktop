variable "automation_account_name" {
  type        = string
  description = "Name of the automation account"
  default     = "AVD-Automation"
}

variable "automation_account_sku" {
  type        = string
  description = "SKU of the automation account"
  default     = "Basic"
}

variable "automation_runbooks" {
  type = map(object({
    file_name = string
    webhook   = bool
    type      = string
    enabled   = optional(bool, true)
  }))
}

variable "domain_join_password" {
  type        = string
  description = "Password used to join AVD hosts to the domain. This will be populated into an azure keyvault for Azure Automation"
  nullable    = true
  default     = null
  sensitive   = true
}

variable "dynamic_host_groups" {
  type = map(object({
    groupName            = string
    groupFilterSubstring = string
  }))
  description = "Objects that will be used to create Entra Dynamic Host Groups"
  default     = {}
}

variable "environments" {
  type = map(object({
    workspace = object({
      workspace_description   = string
      workspace_name          = string
      workspace_friendly_name = string
    })
    host_pools = map(object({
      auth_type                           = string
      custom_rdp_properties               = optional(string, "enablecredsspsupport:i:1;videoplaybackmode:i:1;audiomode:i:0;devicestoredirect:s:*;drivestoredirect:s:*;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;redirectwebauthn:i:1;usbdevicestoredirect:s:*;use multimon:i:1;")
      load_balancer_type                  = string
      host_pool_friendly_name             = string
      host_pool_name                      = string
      host_pool_type                      = string
      maximum_sessions_allowed            = optional(number, 999999)
      personal_desktop_assignment_type    = optional(string, null)
      preferred_app_group_type            = optional(string, "Desktop")
      scaling_plan_enabled                = bool
      scaling_plan_name                   = optional(string)
      scaling_plan_time_zone              = optional(string)
      scheduled_agent_updates             = optional(bool, false)
      scheduled_agent_updates_hour_of_day = optional(number, 0)
      scheduled_agent_updates_day_of_week = optional(string, "Sunday")
      scaling_plan_schedule = optional(object({
        name                                 = string
        days_of_week                         = list(string)
        ramp_up_start_time                   = string
        ramp_up_load_balancing_algorithm     = string
        ramp_up_minimum_hosts_percent        = number
        ramp_up_capacity_threshold_percent   = number
        peak_start_time                      = string
        peak_load_balancing_algorithm        = string
        ramp_down_start_time                 = string
        ramp_down_load_balancing_algorithm   = string
        ramp_down_minimum_hosts_percent      = number
        ramp_down_force_logoff_users         = bool
        ramp_down_wait_time_minutes          = number
        ramp_down_notification_message       = string
        ramp_down_capacity_threshold_percent = number
        ramp_down_stop_hosts_when            = string
        off_peak_start_time                  = string
        off_peak_load_balancing_algorithm    = string
      }))
      start_vm_on_connect = optional(bool, false)
      application_groups = optional(map(object({
        application_group_assignnment_group_name = string
        application_group_friendly_name          = optional(string, null)
        application_group_name                   = string
        application_group_type                   = string
        applications = optional(map(object({
          friendly_name                = optional(string, null)
          name                         = string
          path                         = optional(string, null)
          command_line_argument_policy = optional(string, null)
          command_line_arguments       = optional(string, null)
          icon_path                    = optional(string, null)
          icon_index                   = optional(string, null)
        })))
      })))
    }))
  }))
}

variable "images" {
  type = map(object({
    shared_image_name      = string
    shared_image_sku       = optional(string, null)
    shared_image_offer     = optional(string, null)
    shared_image_publisher = optional(string, null)
  }))
}


variable "keyvault" {
  type = map(object({
    name        = string
    secret_name = optional(string, "domain-join-password")
  }))
  description = "Map of object representing the keyvault to be created"
  default     = {}
}

variable "location" {
  type        = string
  description = "Azure region that all the reources will be placed in"
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Name of the log analytics workspace to be created"
  default     = "law-avd"
}

variable "maintenance_definition" {
  type = map(object({
    maintenance_name                 = string
    maintenance_scope                = string
    maintenance_duration             = optional(string)
    maintenance_start_date_time      = string
    maintenance_end_date_time        = optional(string)
    maintenance_recurrence           = optional(string)
    maintenance_time_zone            = string
    patch_classifications_to_include = optional(list(string), ["Critical", "Security", ])
  }))
}

variable "managed_identity_name" {
  type        = string
  description = "Name of managed identity to create. This will be granted contributor roles on the sub"
  default     = "avd-automation"
}

variable "policy_target_locations" {
  type        = list(string)
  description = "A list of locations to target for the policy assignments for VMs"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to be created"
}

variable "shared_image_gallery_name" {
  type        = string
  description = "Name of the shared image gallery to be created"
}

variable "storage_account" {
  type = object({
    smb_contributor_group_name          = string
    smb_elevated_contributor_group_name = string
    storage_account_name                = string
    storage_account_share = optional(map(object({
      name  = string
      quota = number
    })), {})
    directory_config = map(object({
      directory_type = optional(string)
      active_directory_config = object({
        domain_guid         = optional(string)
        domain_name         = optional(string)
        domain_sid          = optional(string)
        forest_name         = optional(string)
        netbios_domain_name = optional(string)
        storage_sid         = optional(string)
      })
    }))
  })
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet to be created"
}

variable "subscription_id" {
  type        = string
  description = "Subscription Id the resources will be placed in"
}

variable "tenant_id" {
  type        = string
  description = "Tenant ID of azure account"
}

variable "vnet_ip_space" {
  type        = string
  description = "IP Space for the vnet"
}

variable "vnet_dns_servers" {
  type        = list(string)
  description = "DNS servers for vnet"
}

variable "vnet_name" {
  type        = string
  description = "Name of the vNet to be created"
}

