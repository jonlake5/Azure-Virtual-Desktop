variable "location" {
  type        = string
  description = "Location of the AVD workspace"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Id of the log analytics workspace to send logs to"
}

variable "resource_group_name" {
  type        = string
  description = "Name of resource group for the AVD Workspace"
}

variable "workspace_description" {
  type        = string
  description = "Description of workspace"
}

variable "workspace_friendly_name" {
  type        = string
  description = "Friendly name of the workspace"
}

variable "workspace_name" {
  type        = string
  description = "Name of the AVD Workspace"
}
