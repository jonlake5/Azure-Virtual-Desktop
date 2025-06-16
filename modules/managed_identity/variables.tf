
variable "location" {
  type        = string
  description = "Location of the managed identity"
}

variable "managed_identity_name" {
  type        = string
  description = "Name of the managed identity"
}

variable "resource_group_name" {
  type        = string
  description = "Name of resource group for the managed identity"
}

variable "subscription_id" {
  type        = string
  description = "Subscription Id to apply the contributore role of the managed identity"
}
