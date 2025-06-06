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
  subscription_id                 = var.subscription_id
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
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "test_vnet" {
  location            = azurerm_resource_group.avd.location
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.avd.name
  address_space       = [cidrsubnet(var.vnet_ip_space, 0, 0)]
  dns_servers         = var.vnet_dns_servers
}

resource "azurerm_subnet" "test-avd-subnet" {
  name                 = var.subnet_name
  virtual_network_name = azurerm_virtual_network.test_vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_ip_space, 8, 0)]
  resource_group_name  = azurerm_resource_group.avd.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "file" {
  name                  = "link_avd_vnet"
  resource_group_name   = azurerm_resource_group.avd.name
  private_dns_zone_name = azurerm_private_dns_zone.file.name
  virtual_network_id    = azurerm_virtual_network.test_vnet.id
}

resource "azurerm_private_dns_zone" "file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.avd.name
}

resource "azurerm_private_dns_a_record" "storage_pe" {
  name                = module.storage_account.name
  ttl                 = 5
  records             = toset([module.storage_account.private_endpoint_ip_address])
  resource_group_name = azurerm_resource_group.avd.name
  zone_name           = azurerm_private_dns_zone.file.name
  depends_on          = [azurerm_private_dns_zone.file]
}

module "automation" {
  source                      = "./modules/automation"
  location                    = azurerm_resource_group.avd.location
  resource_group_name         = azurerm_resource_group.avd.name
  automation_account_name     = var.automation_account_name
  automation_account_sku_name = var.automation_account_sku
  identity = [{
    identity_ids = [module.managed_identity.managed_identity_id]
  identity_type = "UserAssigned" }]
  runbooks                      = var.automation_runbooks
  tenant_id                     = var.tenant_id
  keyvault_name                 = var.keyvault_name
  domain_join_password          = var.domain_join_password
  managed_identity_principal_id = module.managed_identity.managed_identity_principal_id
}

module "managed_identity" {
  source                = "./modules/managed_identity"
  resource_group_name   = azurerm_resource_group.avd.name
  subscription_id       = data.azurerm_client_config.current.subscription_id
  managed_identity_name = var.managed_identity_name
  location              = azurerm_resource_group.avd.location
}

module "monitoring" {
  source                              = "./modules/monitoring"
  location                            = azurerm_resource_group.avd.location
  resource_group_name                 = azurerm_resource_group.avd.name
  policy_assignment_resource_group_id = azurerm_resource_group.avd.id
  law_name                            = var.log_analytics_workspace_name
  subscription_id                     = data.azurerm_client_config.current.subscription_id
  managed_identity_id                 = module.managed_identity.managed_identity_id
}

module "policies" {
  source              = "./modules/policies"
  managed_identity_id = module.managed_identity.managed_identity_id
  resource_group_name = azurerm_resource_group.avd.name
  location            = azurerm_resource_group.avd.location
}

module "role_assignments" {
  source              = "./modules/avd_role_assignments"
  resource_group_name = azurerm_resource_group.avd.name
  subscription_id     = data.azurerm_client_config.current.subscription_id
  session_host_groups = var.session_host_groups

}

module "shared_image_gallery" {
  source              = "./modules/image_gallery"
  location            = azurerm_resource_group.avd.location
  name                = var.shared_image_gallery_name
  resource_group_name = azurerm_resource_group.avd.name
}

module "shared_image" {
  for_each                  = var.images
  source                    = "./modules/image"
  location                  = azurerm_resource_group.avd.location
  resource_group_name       = azurerm_resource_group.avd.name
  shared_image_gallery_name = module.shared_image_gallery.name
  shared_image_name         = each.value.shared_image_name
  shared_image_sku          = each.value.shared_image_sku
  depends_on                = [module.shared_image_gallery]
}

module "storage_account" {
  source                              = "./modules/storage_account"
  location                            = azurerm_resource_group.avd.location
  resource_group_name                 = azurerm_resource_group.avd.name
  pe_subnet_id                        = azurerm_subnet.test-avd-subnet.id
  smb_contributor_group_name          = var.storage_account.smb_contributor_group_name
  smb_elevated_contributor_group_name = var.storage_account.smb_elevated_contributor_group_name
  storage_account_name                = var.storage_account.storage_account_name
  storage_account_share               = var.storage_account.storage_account_share
  directory_config                    = var.storage_account.directory_config

}

module "updates" {
  source                        = "./modules/vm_updates"
  resource_group_id             = azurerm_resource_group.avd.id
  managed_identity_id           = module.managed_identity.managed_identity_id
  managed_identity_principal_id = module.managed_identity.managed_identity_principal_id
  location                      = azurerm_resource_group.avd.location
  resource_group_name           = azurerm_resource_group.avd.name
  policy_target_locations       = var.policy_target_locations
  maintenance_definition        = var.maintenance_definition
}

output "keyvault_name" {
  value = module.automation.keyvault_name
}

output "keyvault_secret" {
  value = module.automation.keyvault_secret
}

output "managed_identity_object_id" {
  value = module.managed_identity.managed_identity_id
}

output "maintenance_config_name" {
  value = module.updates.maintenance_config_name
}

output "webhook_uri" {
  value     = module.automation.webhook_url
  sensitive = true
}
