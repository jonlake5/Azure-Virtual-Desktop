locals {
  subscription_scope = "/subscriptions/${var.subscription_id}"
}

resource "azurerm_role_assignment" "contributor" {
  scope                = local.subscription_scope
  principal_id         = azurerm_user_assigned_identity.monitoring.principal_id
  role_definition_name = "Contributor"
}

resource "azurerm_user_assigned_identity" "monitoring" {
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = var.managed_identity_name
}

output "managed_identity_id" {
  value = azurerm_user_assigned_identity.monitoring.id
}

output "managed_identity_principal_id" {
  value = azurerm_user_assigned_identity.monitoring.principal_id
}

