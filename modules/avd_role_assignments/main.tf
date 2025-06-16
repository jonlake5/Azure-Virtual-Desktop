data "azuread_service_principal" "avd" {
  display_name = "Azure Virtual Desktop"
}

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}
locals {
  subscription_scope = "/subscriptions/${var.subscription_id}"
}
resource "azurerm_role_assignment" "dv_poweron_poweroff" {
  scope                = local.subscription_scope
  principal_id         = data.azuread_service_principal.avd.object_id
  role_definition_name = "Desktop Virtualization Power On Off Contributor"
}

data "azuread_group" "group" {
  for_each     = toset(var.application_group_assignment_groups)
  display_name = each.value
}

resource "azurerm_role_assignment" "vm_user_login" {
  for_each             = toset(var.application_group_assignment_groups)
  scope                = data.azurerm_resource_group.resource_group.id
  principal_id         = data.azuread_group.group[each.value].object_id
  role_definition_name = "Virtual Machine User Login"
}
