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

resource "azurerm_automation_variable_string" "string" {
  count                   = length(var.automation_variables)
  name                    = var.automation_variables[count.index].key
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation.name
  value                   = var.automation_variables[count.index].value

}

resource "azurerm_automation_runbook" "runbook" {
  for_each                = var.runbooks
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
  for_each                = var.runbooks
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

resource "azurerm_automation_module" "az_compute" {
  name                    = "Az.Compute"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation.name
  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/Az.Compute/10.0.0"
  }

}

# This doesn't seem to work, so manually will need to import 10.0.0
# resource "null_resource" "install_az_compute_ps72" {
#   provisioner "local-exec" {
#     command = <<EOT
# az extension add --name automation

# az automation module create \
#   --automation-account-name "${azurerm_automation_account.automation.name}" \
#   --resource-group "${var.resource_group_name}" \
#   --name "Az.Compute" \
#   --content-link "https://www.powershellgallery.com/api/v2/package/Az.Compute/10.0.0" \
#   --runtime-version "7.2"
# EOT
#   }
#   triggers = {
#     always_run = timestamp()
#   }
#   depends_on = [azurerm_automation_account.automation, azurerm_automation_runbook.runbook]
# }

resource "azurerm_key_vault" "key_vault" {
  resource_group_name       = var.resource_group_name
  location                  = var.location
  name                      = var.keyvault_name
  sku_name                  = "standard"
  tenant_id                 = var.tenant_id
  enable_rbac_authorization = true
}

resource "azurerm_key_vault_secret" "secret" {
  name         = var.keyvault_secret_name
  key_vault_id = azurerm_key_vault.key_vault.id
  value        = var.domain_join_password
  depends_on   = [azurerm_role_assignment.tf_read_write_key_vault]

}

data "azurerm_client_config" "current" {}


resource "azurerm_role_assignment" "tf_read_write_key_vault" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "managed_identity_read_write_key_vault" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.managed_identity_principal_id
}


output "keyvault_name" {
  value = azurerm_key_vault.key_vault.name
}

output "keyvault_secret" {
  value = azurerm_key_vault_secret.secret.name
}

output "webhook_url" {
  value = toset([for k in azurerm_automation_webhook.webhook : join(" => ", [k.name, k.uri])])
}
