terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.26.0"

    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.4.2"

    }
    azapi = {
      source  = "Azure/azapi"
      version = "~>2.4.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~>0.13.1"
    }
  }
}
provider "azurerm" {
  #   use_oidc = true
  features {}
  subscription_id                 = "074f4b99-ea66-4a73-a146-d342db9d1e92"
  resource_provider_registrations = "none"
}
provider "azapi" {
}

# provider "azuread" {
#   tenant_id = var.tenant_id
#   use_oidc  = true
# }

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "avd" {
  name     = "rg-testing-avd-modules"
  location = "northcentralus"
}

resource "azurerm_virtual_network" "test_vnet" {
  location            = azurerm_resource_group.avd.location
  name                = "test-avd-vnet"
  resource_group_name = azurerm_resource_group.avd.name
  address_space       = [cidrsubnet("10.0.0.0/16", 0, 0)]
  dns_servers         = ["10.0.0.17", "8.8.8.8"]
}

resource "azurerm_subnet" "test-avd-subnet" {
  name                 = "test-avd-subnet"
  virtual_network_name = azurerm_virtual_network.test_vnet.name
  address_prefixes     = [cidrsubnet("10.0.0.0/16", 8, 0)]
  resource_group_name  = azurerm_resource_group.avd.name
}

# Role Assignments
module "role_assignments" {
  source              = "./modules/avd_role_assignments"
  resource_group_name = azurerm_resource_group.avd.name
  subscription_id     = data.azurerm_client_config.current.subscription_id
  session_host_groups = var.session_host_groups

}

# Shared Image Gallery
module "shared_image_gallery" {
  source              = "./modules/image_gallery"
  location            = azurerm_resource_group.avd.location
  name                = "NC_US_Shared_Gallery"
  resource_group_name = azurerm_resource_group.avd.name
}

#Shared Image
module "shared_image" {
  for_each                  = var.images
  source                    = "./modules/image"
  location                  = azurerm_resource_group.avd.location
  resource_group_name       = azurerm_resource_group.avd.name
  shared_image_gallery_name = module.shared_image_gallery.name
  golden_image_name         = each.value.golden_image_name
  golden_image_vm_name      = each.value.golden_image_vm_name
  local_admin_password      = each.value.local_admin_password
  local_admin_username      = each.value.local_admin_password
  subscription_id           = data.azurerm_client_config.current.subscription_id
  subnet_id                 = azurerm_subnet.test-avd-subnet.id
  shared_image_name         = each.value.shared_image_name
  shared_image_sku          = each.value.shared_image_sku
  shared_image_version_name = each.value.shared_image_version_name
  depends_on                = [module.shared_image_gallery]
}

# #Storage Account
# module "storage_account" {
#   source                              = "./modules/storage_account"
#   location                            = azurerm_resource_group.avd.location
#   resource_group_name                 = azurerm_resource_group.avd.name
#   pe_subnet_id                        = azurerm_subnet.test-avd-subnet.id
#   smb_contributor_group_name          = var.storage_account.smb_contributor_group_name
#   smb_elevated_contributor_group_name = var.storage_account.smb_elevated_contributor_group_name
#   storage_account_name                = var.storage_account.storage_account_name
#   storage_account_share               = var.storage_account.storage_account_share
#   directory_config                    = var.storage_account.directory_config
# }

module "monitoring" {
  source                              = "./modules/monitoring"
  location                            = azurerm_resource_group.avd.location
  resource_group_name                 = azurerm_resource_group.avd.name
  policy_assignment_resource_group_id = azurerm_resource_group.avd.id
  law_name                            = "law-avd"        # Should be variablized.
  managed_identity_name               = "avd-automation" # This creates a managed identity. It should probably be pulled out to the main module as it is used by Automation module as well.
  subscription_id                     = data.azurerm_client_config.current.subscription_id
}

module "policies" {
  source              = "./modules/policies"
  managed_identity_id = module.monitoring.managed_identity_id
  resource_group_name = azurerm_resource_group.avd.name
  location            = azurerm_resource_group.avd.location
}

module "updates" {
  source                        = "./modules/vm_updates"
  resource_group_id             = azurerm_resource_group.avd.id
  managed_identity_id           = module.monitoring.managed_identity_id
  managed_identity_principal_id = module.monitoring.managed_identity_principal_id
  location                      = azurerm_resource_group.avd.location
  resource_group_name           = azurerm_resource_group.avd.name
  policy_target_locations       = var.policy_target_locations
  maintenance_definition        = var.maintenance_definition
}

module "automation" {
  source                      = "./modules/automation"
  location                    = azurerm_resource_group.avd.location
  resource_group_name         = azurerm_resource_group.avd.name
  automation_account_name     = "AVD-Automation"
  automation_account_sku_name = "Basic"
  identity = [{
    identity_ids = [module.monitoring.managed_identity_id]
  identity_type = "UserAssigned" }]
  runbooks                      = var.automation_runbooks
  tenant_id                     = var.tenant_id
  keyvault_name                 = var.keyvault_name
  domain_join_password          = var.domain_join_password
  managed_identity_principal_id = module.monitoring.managed_identity_principal_id
}

output "keyvault_name" {
  value = module.automation.keyvault_name
}

output "keyvault_secret" {
  value = module.automation.keyvault_secret
}

output "managed_identity_object_id" {
  value = module.monitoring.managed_identity_id
}

output "maintenance_config_name" {
  value = module.updates.maintenance_config_name
}

output "webhook_uri" {
  value     = module.automation.webhook_url
  sensitive = true
}

