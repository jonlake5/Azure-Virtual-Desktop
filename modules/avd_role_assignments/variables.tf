variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "session_host_groups" {
  type        = list(string)
  description = "A list of groups that are used to provide apps to session hosts that are entra joined"
}


variable "subscription_id" {
  type        = string
  description = "Subscription ID this is being deployed into"
}
