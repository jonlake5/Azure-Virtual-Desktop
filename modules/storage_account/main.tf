resource "azurerm_storage_account" "avd" {
  resource_group_name           = var.resource_group_name
  account_replication_type      = var.storage_account_replication_type
  account_tier                  = var.storage_account_tier
  account_kind                  = var.storage_account_kind
  location                      = var.location
  name                          = var.storage_account_name
  public_network_access_enabled = var.storage_account_public_network_access_enabled
  dynamic "azure_files_authentication" {
    for_each = var.directory_config
    content {
      directory_type = azure_files_authentication.value.directory_type
      dynamic "active_directory" {
        for_each = var.directory_config
        content {
          domain_guid         = active_directory.value.active_directory_config.domain_guid
          domain_name         = active_directory.value.active_directory_config.domain_name
          domain_sid          = active_directory.value.directory_type == "AD" ? active_directory.value.active_directory_config.domain_sid : null
          forest_name         = active_directory.value.directory_type == "AD" ? active_directory.value.active_directory_config.forest_name : null
          netbios_domain_name = active_directory.value.directory_type == "AD" ? active_directory.value.active_directory_config.netbios_domain_name : null
          storage_sid         = active_directory.value.directory_type == "AD" ? active_directory.value.active_directory_config.storage_sid : null
        }
      }
    }
  }
}

resource "azurerm_storage_account_network_rules" "avd" {
  storage_account_id = azurerm_storage_account.avd.id
  default_action     = var.storage_account_network_rules_default_action
}

resource "azurerm_storage_share" "FSXShare" {
  for_each           = var.storage_account_share
  name               = each.value.name
  depends_on         = [azurerm_storage_account.avd]
  quota              = each.value.quota
  storage_account_id = azurerm_storage_account.avd.id
}

data "azurerm_role_definition" "smb_contributor" {
  name = "Storage File Data SMB Share Contributor"
}
data "azurerm_role_definition" "smb_elevated_contributor" {
  name = "Storage File Data SMB Share Elevated Contributor"
}

data "azuread_group" "smb_contributor" {
  display_name = var.smb_contributor_group_name
}

resource "azurerm_role_assignment" "smb_contributor" {
  scope                = azurerm_storage_account.avd.id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = data.azuread_group.smb_contributor.object_id
}

data "azuread_group" "smb_elevated_contributor" {
  display_name = var.smb_elevated_contributor_group_name
}


resource "azurerm_role_assignment" "smb_elevated_contributor" {
  scope                = azurerm_storage_account.avd.id
  role_definition_name = "Storage File Data SMB Share Elevated Contributor"
  principal_id         = data.azuread_group.smb_elevated_contributor.object_id
}



# Private Endpoint
resource "azurerm_private_endpoint" "file_storage" {
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = "pe-${azurerm_storage_account.avd.name}"
  subnet_id           = var.pe_subnet_id
  private_service_connection {
    name                           = "${azurerm_storage_account.avd.name}-privateserviceconnection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.avd.id
    subresource_names              = ["file"]
  }
}

output "name" {
  value = azurerm_storage_account.avd.name
}
output "private_endpoint_ip_address" {
  value = azurerm_private_endpoint.file_storage.private_service_connection[0].private_ip_address
}
