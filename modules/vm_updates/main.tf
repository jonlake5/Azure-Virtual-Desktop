resource "azurerm_resource_group_policy_assignment" "update_prereqs" {
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/9905ca54-1471-49c6-8291-7582c04cd4d4"
  resource_group_id    = var.resource_group_id
  location             = var.location
  name                 = "Prerequisites for recurring updates on Azure virtual machines"
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }
}


resource "azurerm_resource_group_policy_assignment" "check_updates" {
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/bd876905-5b84-4f73-ab2d-2e7a7c4568d9"
  resource_group_id    = var.resource_group_id
  location             = var.location
  name                 = "Periodically check for missing system updates"
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }
}
