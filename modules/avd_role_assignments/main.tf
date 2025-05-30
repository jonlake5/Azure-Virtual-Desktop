data "azuread_service_principal" "avd" {
  display_name = "Azure Virtual Desktop"
}

locals {
  subscription_scope = "/subscriptions/${var.subscription_id}"
}
resource "azurerm_role_assignment" "dv_poweron_poweroff" {
  scope                = local.subscription_scope
  principal_id         = data.azuread_service_principal.avd.object_id
  role_definition_name = "Desktop Virtualization Power On Off Contributor"
}
