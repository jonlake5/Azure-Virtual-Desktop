variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "application_group_assignment_groups" {
  type        = list(string)
  description = "A list of groups that provide assignments of groups to application groups"
}


variable "subscription_id" {
  type        = string
  description = "Subscription ID this is being deployed into"
}
