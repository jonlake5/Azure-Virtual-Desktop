variable "directory_config" {
  type = map(object({
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
}

variable "location" {
  type        = string
  description = "Location of the storage account"
}
variable "pe_subnet_id" {
  type        = string
  description = "Subnet id to put the private endpoint in for the file share"
}

variable "resource_group_name" {
  type        = string
  description = "Name of resource group for the shared gallery"
}

variable "smb_contributor_group_name" {
  type        = string
  description = "Name of group that will be assigned SMB Contributor role"
}

variable "smb_elevated_contributor_group_name" {
  type        = string
  description = "Name of group that will be assigned SMB Elevated Contributor role"
}
variable "storage_account_kind" {
  type        = string
  description = "Type of storage account, i.e. FileStorage"
  default     = "FileStorage"
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account to create"
}
variable "storage_account_network_rules_default_action" {
  type        = string
  description = "Default Action on storage network account"
  default     = "Deny"
}

variable "storage_account_public_network_access_enabled" {
  type        = bool
  description = "True enables public access, false disables"
  default     = false
}

variable "storage_account_replication_type" {
  type        = string
  description = "Replication type of storage account"
  default     = "LRS"
}

variable "storage_account_share" {
  type = map(object({
    name  = string
    quota = number
  }))
}

variable "storage_account_tier" {
  type        = string
  description = "Tier of storage account (Premium or General Purpose)"
  default     = "Premium"
}
