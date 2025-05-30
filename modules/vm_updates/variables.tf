variable "location" {
  type        = string
  description = "Location of the shared image gallery"
}

variable "managed_identity_id" {
  type        = string
  description = "Id of the managed identity used for policy assignments"
}
variable "managed_identity_principal_id" {
  type        = string
  description = "Principal ID of the managed identity that will run the remediations"
}
variable "resource_group_id" {
  type        = string
  description = "Resource Group Id to assign the policy scope to"
}
variable "resource_group_name" {
  type        = string
  description = "Name of resource group for the shared gallery"
}
