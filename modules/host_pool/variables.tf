variable "custom_rdp_properties" {
  type = string
  # nullable = true
}

variable "host_pool_friendly_name" {
  type        = string
  description = "Friendly name of the host pool"
}

variable "host_pool_name" {
  type        = string
  description = "Name of the hostpool"
}

variable "host_pool_type" {
  type        = string
  description = "Type of host pool (personal or pooled)"
  validation {
    condition     = contains(["Pooled", "Personal"], var.host_pool_type)
    error_message = "Value must contain one of (Pooled, Personal)"
  }
}

variable "load_balancer_type" {
  type        = string
  description = "Type of load balancing of user sessions on the host pool"
  validation {
    condition     = contains(["BreadthFirst", "DepthFirst", "Persistent"], var.load_balancer_type)
    error_message = "Value must contain one of (BreadthFirst, DepthFirst, Persistent)"
  }
}

variable "location" {
  type        = string
  description = "Location of the host pool"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "The Log Analytics workspace to send the diagnostic data to"
}

variable "maximum_sessions_allowed" {
  type        = number
  description = "Number of sessions per host"
  validation {
    condition     = (0 < var.maximum_sessions_allowed && var.maximum_sessions_allowed <= 999999)
    error_message = "The value must be between 0 and 999999"
  }
  default = 1
}

variable "personal_desktop_assignment_type" {
  type        = string
  description = "Automatic assignment - The service will select an available host and assign it to an user. Possible values are Automatic and Direct. Direct Assignment – Admin selects a specific host to assign to an user. Changing this forces a new resource to be created."
  default     = null
  nullable    = true
}

variable "preferred_app_group_type" {
  type        = string
  description = "Option to specify the preferred Application Group type for the Virtual Desktop Host Pool"
  default     = "Desktop"
}

variable "resource_group_name" {
  type        = string
  description = "Name of resource group for the host pool"
}

variable "scaling_plan_enabled" {
  type        = bool
  description = "Defines whether or not the scaling plan is enabled"
}

variable "scaling_plan_name" {
  type        = string
  description = "Name of the host pool scaling plan"
}

variable "scaling_plan_time_zone" {
  type        = string
  description = "Timezone of the scaling plan"
}

variable "scaling_plan_schedule" {
  type = object({
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
  })

}

variable "scheduled_agent_updates" {
  type        = bool
  description = "Whether or not to enable scheduled updates of the AVD agent"
  default     = false
}

variable "scheduled_agent_updates_day_of_week" {
  type        = string
  description = "Day of week to have scheduled agent updates enabled"
  nullable    = true
  default     = "Sunday"
  validation {
    condition = var.scheduled_agent_updates_day_of_week == null ? false : (
    contains(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], var.scheduled_agent_updates_day_of_week))
    error_message = "Must contain one of (Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday)"
  }
}

variable "scheduled_agent_updates_hour_of_day" {
  type        = number
  description = "Hour of day to schedule the agent updates"
  default     = 0
  validation {
    condition     = ((0 <= var.scheduled_agent_updates_hour_of_day && var.scheduled_agent_updates_hour_of_day <= 24) || (var.scheduled_agent_updates_hour_of_day == null))
    error_message = "Value must be between 0 and 24"
  }
}
variable "start_vm_on_connect" {
  type        = bool
  description = "Whether to start VM on connect or not"
  default     = false
}

variable "validate_environment" {
  type        = bool
  description = "Whether or not to validate the environment"
  default     = false
}
