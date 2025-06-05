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
      load_balancer_type      = string
      host_pool_friendly_name = string
      host_pool_name          = string
      host_pool_type          = string
      scaling_plan_enabled    = bool
      scaling_plan_name       = optional(string)
      scaling_plan_time_zone  = string
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
      application_groups = optional(map(object({

        application_group_assignnment_group_name = string
        application_group_name                   = string
        application_group_type                   = string
        applications = optional(map(object({
          friendly_name = string
          name          = string
          path          = string
        })))
      })))
    }))
  }))
}

variable "images" {
  type = map(object({
    golden_image_name         = string
    golden_image_vm_name      = string
    local_admin_password      = string
    local_admin_username      = string
    shared_image_name         = string
    shared_image_sku          = string
    shared_image_version_name = string
  }))
  validation {
    condition = alltrue([
      for image in var.images : length(image.golden_image_vm_name) <= 15
    ])
    error_message = "Each golden_image_vm_name must be 15 characters or fewer."
  }
}

variable "keyvault_name" {
  type        = string
  description = "Name or keyvault used to store secret of domain join password"
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

variable "policy_target_locations" {
  type        = list(string)
  description = "A list of locations to target for the policy assignments for VMs"
}

variable "storage_account" {
  type = object({
    smb_contributor_group_name          = string
    smb_elevated_contributor_group_name = string
    storage_account_name                = string
    storage_account_share = map(object({
      name  = string
      quota = number
    }))
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


variable "tenant_id" {
  type        = string
  description = "Tenant ID of azure account"
}
