data "azurerm_client_config" "current" {}

resource "azurerm_automation_account" "automation" {
  name                = var.automation_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.automation_account_sku_name
  dynamic "identity" {
    for_each = var.identity
    content {
      type         = identity.value.identity_type
      identity_ids = identity.value.identity_ids
    }
  }
}

resource "azurerm_automation_variable_string" "account_id" {
  name                    = "accountId"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation.name
  value                   = var.managed_identity_principal_id
}

resource "azurerm_automation_variable_string" "string" {
  count                   = length(var.automation_variables)
  name                    = var.automation_variables[count.index].key
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation.name
  value                   = var.automation_variables[count.index].value
}

resource "azurerm_automation_runbook" "runbook" {
  for_each                = { for k, v in var.runbooks : k => v if v.enabled }
  resource_group_name     = var.resource_group_name
  location                = var.location
  log_verbose             = false
  automation_account_name = azurerm_automation_account.automation.name
  log_progress            = false
  runbook_type            = each.value.type
  name                    = split(".ps1", each.value.file_name)[0]
  content                 = file("${path.module}/runbooks/${each.value.file_name}")
  publish_content_link {
    uri = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/c4935ffb69246a6058eb24f54640f53f69d3ac9f/101-automation-runbook-getvms/Runbooks/Get-AzureVMTutorial.ps1"
  }

}

resource "azurerm_automation_webhook" "webhook" {
  for_each                = { for k, v in var.runbooks : k => v if v.webhook && v.enabled }
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation.name
  runbook_name            = split(".ps1", each.value.file_name)[0]
  name                    = "${split(".ps1", each.value.file_name)[0]}-webhook"
  expiry_time             = timeadd(timestamp(), "999h")
  lifecycle {
    ignore_changes = [expiry_time]
  }
  depends_on = [azurerm_automation_runbook.runbook]
}

locals {
  az_modules = {
    az_compute = {
      uri  = "https://www.powershellgallery.com/api/v2/package/Az.Compute/10.0.0"
      name = "Az.Compute"
    }
    az_accounts = {
      uri  = "https://www.powershellgallery.com/api/v2/package/Az.Accounts/5.0.1"
      name = "Az.Accounts"
    }
    az = {
      uri  = "https://www.powershellgallery.com/api/v2/package/Az/14.0.0"
      name = "Az"
    }
  }
}
resource "azurerm_automation_powershell72_module" "module" {
  for_each              = local.az_modules
  name                  = each.value.name
  automation_account_id = azurerm_automation_account.automation.id
  module_link {
    uri = each.value.uri
  }
}

resource "azurerm_key_vault" "key_vault" {
  for_each                  = var.keyvault
  resource_group_name       = var.resource_group_name
  location                  = var.location
  name                      = each.value.name
  sku_name                  = "standard"
  tenant_id                 = var.tenant_id
  enable_rbac_authorization = true
}

resource "azurerm_key_vault_secret" "secret" {
  for_each     = var.keyvault
  name         = each.value.secret_name
  key_vault_id = azurerm_key_vault.key_vault[each.key].id
  value        = var.domain_join_password
  depends_on   = [azurerm_role_assignment.tf_read_write_key_vault]

}

resource "azurerm_role_assignment" "tf_read_write_key_vault" {
  for_each             = var.keyvault
  scope                = azurerm_key_vault.key_vault[each.key].id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "managed_identity_read_write_key_vault" {
  for_each             = var.keyvault
  scope                = azurerm_key_vault.key_vault[each.key].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.managed_identity_principal_id
}

output "keyvault_name_and_secret" {
  value = [for k, v in var.keyvault : join(" : ", [azurerm_key_vault.key_vault[k].name, azurerm_key_vault_secret.secret[k].name])]
}

output "webhook_url" {
  value = toset([for k in azurerm_automation_webhook.webhook : join(" => ", [k.name, k.uri])])
}
