variable "automation_account_name" {
  type        = string
  description = "Name of the automation account"
}

variable "automation_account_sku_name" {
  type        = string
  description = "SKU of automation account"
}

variable "automation_variables" {
  type        = list(object({ key = string, value = string }))
  description = "List of variables to apply to the automation account"
  default     = []
}

variable "identity" {
  type = list(object({
    identity_ids  = list(string)
    identity_type = string
  }))
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Name of resource group for the shared gallery"
}

variable "runbooks" {
  type = map(object({
    file_name = string
    webhook   = bool
    type      = string
  }))
  description = "Map of objects defining the runbook"
}
