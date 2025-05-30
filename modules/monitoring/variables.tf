variable "ama_install_policy_assignment_name" {
  type    = string
  default = "Azure Monitoring Agent Policy"
}

variable "law_name" {
  type        = string
  description = "Name of log analytics workspace"
}

variable "location" {
  type        = string
  description = "Location of the shared image gallery"
}

variable "managed_identity_name" {
  type        = string
  description = "Name of the Managed Identity"
}

variable "policy_assignment_resource_group_id" {
  type        = string
  description = "Resource Group Id to assign the policy to"
}


variable "resource_group_name" {
  type        = string
  description = "Name of resource group for the shared gallery"
}

variable "subscription_id" {
  type        = string
  description = "Subscription Id to apply the contributore role of the managed identity"
}
