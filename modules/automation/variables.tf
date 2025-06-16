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
variable "domain_join_password" {
  type        = string
  description = "Password used for domain join of the AVD hosts"
  sensitive   = true
}

variable "identity" {
  type = list(object({
    identity_ids  = list(string)
    identity_type = string
  }))
}

variable "keyvault" {
  type = map(object({
    name        = string
    secret_name = optional(string, "domain-join-password")
  }))
  description = "Map of object representing the keyvault to be created"
}

variable "location" {
  type        = string
  description = "Azure region for the automation account"
}
variable "managed_identity_principal_id" {
  type        = string
  description = "Principal ID of the Managed Identity used to access keyvault"
}

variable "resource_group_name" {
  type        = string
  description = "Name of resource group for the automation account"
}

variable "runbooks" {
  type = map(object({
    file_name = string
    webhook   = bool
    type      = string
    enabled   = bool
  }))
  description = "Map of objects defining the runbook"
}

variable "tenant_id" {
  type        = string
  description = "Tenant ID of Azure account"
}
