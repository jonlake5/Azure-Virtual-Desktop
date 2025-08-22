variable "applications" {
  description = "A map of objects outlining applications to be published in the application group"
  type = map(object({
    name                         = string
    friendly_name                = string
    path                         = string
    command_line_argument_policy = optional(string, "DoNotAllow")
    command_line_arguments       = optional(string, null)
    icon_path                    = optional(string, null)
    icon_index                   = optional(string, null)
  }))
  default = {}
}

variable "application_group_assignnment_group_name" {
  type        = string
  description = "Name of Entra Group that will be provided access to this application group"
}

variable "application_group_friendly_name" {
  type        = string
  description = "Friendly name of the application group"
  nullable    = true
  default     = null
}

variable "application_group_name" {
  type        = string
  description = "Name of the Application Group"
}

variable "application_group_type" {
  type        = string
  description = "Type of application group. Allowed Values are \"RemoteApp\" and \"Desktop\""
  validation {
    condition     = contains(["RemoteApp", "Desktop"], var.application_group_type)
    error_message = "Please use one of the allowed values of \"RemoteApp\" or \"Desktop\""
  }
}

variable "default_desktop_display_name" {
  type        = string
  description = "Friendly display name of Session Desktop"
  default     = "SessionDesktop"
}

variable "host_pool_id" {
  type        = string
  description = "Host Pool ID to associate this application group with"
}

variable "location" {
  type        = string
  description = "Location of the application group"
}

variable "resource_group_name" {
  type        = string
  description = "Name of resource group for the application group"
}

variable "workspace_id" {
  type        = string
  description = "Workspace ID to associate this application group with"
}
