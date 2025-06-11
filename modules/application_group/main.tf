resource "azurerm_virtual_desktop_application_group" "application_group" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.application_group_name
  type                = var.application_group_type
  host_pool_id        = var.host_pool_id
  friendly_name       = var.application_group_friendly_name
}

resource "azurerm_virtual_desktop_application" "application" {
  for_each = var.application_group_type == "RemoteApp" ? var.applications : {}
  # for_each                     = var.applications
  name                         = each.value.name
  friendly_name                = each.value.friendly_name
  application_group_id         = azurerm_virtual_desktop_application_group.application_group.id
  path                         = each.value.path
  command_line_argument_policy = coalesce(each.value.command_line_argument_policy, "DoNotAllow")
  command_line_arguments       = each.value.command_line_arguments
  icon_path                    = each.value.icon_path
  icon_index                   = each.value.icon_index
}


resource "azurerm_virtual_desktop_workspace_application_group_association" "ws_ag_association" {
  application_group_id = azurerm_virtual_desktop_application_group.application_group.id
  workspace_id         = var.workspace_id
}

data "azuread_group" "assignment_group" {
  display_name = var.application_group_assignnment_group_name
}

resource "azurerm_role_assignment" "application_group_dv_user" {
  scope                = azurerm_virtual_desktop_application_group.application_group.id
  principal_id         = data.azuread_group.assignment_group.object_id
  role_definition_name = "Desktop Virtualization User"
}

