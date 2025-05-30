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
  description = "Location of the shared image gallery"
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

variable "resource_group_name" {
  type        = string
  description = "Name of resource group for the shared gallery"
}

variable "registration_key_valid_hours" {
  type        = number
  description = "Number of hours the registration key for the host pool should be valid for"
  default     = 2
  validation {
    condition     = var.registration_key_valid_hours > 1 && var.registration_key_valid_hours <= 720
    error_message = "Value must be between 2 and 720"
  }
}

variable "scaling_plan_name" {
  type = string
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
