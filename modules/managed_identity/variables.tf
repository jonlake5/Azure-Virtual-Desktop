
variable "location" {
  type        = string
  description = "Location of the shared image gallery"
}

variable "managed_identity_name" {
  type        = string
  description = "Name of the Managed Identity"
}


variable "resource_group_name" {
  type        = string
  description = "Name of resource group for the shared gallery"
}

variable "subscription_id" {
  type        = string
  description = "Subscription Id to apply the contributore role of the managed identity"
}
