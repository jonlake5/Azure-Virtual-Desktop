variable "location" {
  type        = string
  description = "Location of the shared image gallery"
}

variable "managed_identity_id" {
  type        = string
  description = "Id of the managed identity used for policy assignments"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to assign the policy"
}
