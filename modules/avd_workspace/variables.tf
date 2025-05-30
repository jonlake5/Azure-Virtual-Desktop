variable "location" {
  type        = string
  description = "Location of the shared image gallery"
}

variable "resource_group_name" {
  type        = string
  description = "Name of resource group for the shared gallery"
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
