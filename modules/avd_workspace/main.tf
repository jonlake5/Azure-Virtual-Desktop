resource "azurerm_virtual_desktop_workspace" "workspace" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name          = var.workspace_name
  friendly_name = var.workspace_friendly_name
  description   = var.workspace_description
}

output "workspace_id" {
  value = azurerm_virtual_desktop_workspace.workspace.id
}
