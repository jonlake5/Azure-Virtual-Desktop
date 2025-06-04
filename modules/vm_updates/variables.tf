variable "location" {
  type        = string
  description = "Location of the shared image gallery"
}

variable "maintenance_definition" {
  type = map(object({
    maintenance_name            = string
    maintenance_scope           = string
    maintenance_duration        = optional(string)
    maintenance_start_date_time = string
    maintenance_end_date_time   = optional(string)
    maintenance_recurrence      = optional(string)
    maintenance_time_zone       = string
  }))
}

variable "managed_identity_id" {
  type        = string
  description = "Id of the managed identity used for policy assignments"
}
variable "managed_identity_principal_id" {
  type        = string
  description = "Principal ID of the managed identity that will run the remediations"
}

variable "policy_target_locations" {
  type        = list(string)
  description = "A list of locations to target the policy assignments to"
}

variable "resource_group_id" {
  type        = string
  description = "Resource Group Id to assign the policy scope to"
}
variable "resource_group_name" {
  type        = string
  description = "Name of resource group for the shared gallery"
}
