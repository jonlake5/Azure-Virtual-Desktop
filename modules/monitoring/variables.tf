variable "ama_install_policy_assignment_name" {
  type    = string
  default = "Azure Monitoring Agent Policy"
}

variable "action_group_name" {
  type        = string
  description = "Name of Action Group"
}

variable "action_group_short_name" {
  type        = string
  description = "Short name of action group. Used in SMS"
}

variable "email_receivers" {
  type = list(object({
    name                    = string
    email_address           = string
    use_common_alert_schema = bool
  }))
}

variable "law_name" {
  type        = string
  description = "Name of log analytics workspace"
}

variable "location" {
  type        = string
  description = "Location of the log analytics workspace"
}

variable "managed_identity_id" {
  type        = string
  description = "Managed Identity Id for policy remediation"

}

variable "policy_assignment_resource_group_id" {
  type        = string
  description = "Resource Group Id to assign the policy to"
}

variable "resource_group_name" {
  type        = string
  description = "Name of resource group for the log analytics workspace"
}

variable "subscription_id" {
  type        = string
  description = "Subscription Id to apply the contributore role of the managed identity"
}
