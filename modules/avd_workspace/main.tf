resource "azurerm_virtual_desktop_workspace" "workspace" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name          = var.workspace_name
  friendly_name = var.workspace_friendly_name
  description   = var.workspace_description
}

resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting" {
  name                       = "${azurerm_virtual_desktop_workspace.workspace.name}-diagnostic-setting"
  target_resource_id         = azurerm_virtual_desktop_workspace.workspace.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log {
    category_group = "AllLogs"
  }
}

output "workspace_id" {
  value = azurerm_virtual_desktop_workspace.workspace.id
}
