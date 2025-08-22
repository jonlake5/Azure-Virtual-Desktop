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
  # use_oidc = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
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

resource "azurerm_virtual_network" "avd" {
  location            = azurerm_resource_group.avd.location
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.avd.name
  address_space       = [cidrsubnet(var.vnet_ip_space, 0, 0)]
  dns_servers         = var.vnet_dns_servers
}

resource "azurerm_subnet" "avd" {
  name                 = var.subnet_name
  virtual_network_name = azurerm_virtual_network.avd.name
  address_prefixes     = [cidrsubnet(var.vnet_ip_space, 8, 0)]
  resource_group_name  = azurerm_resource_group.avd.name
}

resource "azurerm_virtual_network_peering" "to_hub" {
  for_each                     = var.vnet_peerings
  resource_group_name          = azurerm_resource_group.avd.name
  name                         = each.value.name
  virtual_network_name         = azurerm_virtual_network.avd.name
  remote_virtual_network_id    = each.value.hub_vnet_id
  allow_virtual_network_access = each.value.spoke.allow_virtual_network
  use_remote_gateways          = each.value.spoke.use_remote_gateways
  allow_forwarded_traffic      = each.value.spoke.allow_forwarded_traffic
}

resource "azurerm_virtual_network_peering" "from_hub" {
  for_each                  = var.vnet_peerings
  resource_group_name       = coalesce(each.value.hub_resource_group_name, azurerm_resource_group.avd.name)
  name                      = each.value.name
  virtual_network_name      = each.value.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.avd.id
  use_remote_gateways       = each.value.hub.use_remote_gateways
  allow_forwarded_traffic   = false
  allow_gateway_transit     = each.value.hub.allow_gateway_transit
}

resource "azurerm_private_dns_zone_virtual_network_link" "file" {
  name                  = "link_avd_vnet"
  resource_group_name   = azurerm_resource_group.avd.name
  private_dns_zone_name = azurerm_private_dns_zone.file.name
  virtual_network_id    = azurerm_virtual_network.avd.id
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
  # source = "./modules/automation"
  source                      = "github.com/jonlake5/Azure-Virtual-Desktop//modules/automation/?ref=1.2.0"
  location                    = azurerm_resource_group.avd.location
  resource_group_name         = azurerm_resource_group.avd.name
  automation_account_name     = var.automation_account_name
  automation_account_sku_name = var.automation_account_sku
  identity = [{
    identity_ids = [module.managed_identity.managed_identity_id]
  identity_type = "UserAssigned" }]
  runbooks                      = var.automation_runbooks
  tenant_id                     = var.tenant_id
  keyvault                      = var.keyvault
  domain_join_password          = var.domain_join_password
  managed_identity_principal_id = module.managed_identity.managed_identity_principal_id
  depends_on                    = [azurerm_resource_group.avd]
}

module "managed_identity" {
  source                = "github.com/jonlake5/Azure-Virtual-Desktop//modules/managed_identity/?ref=1.2.0"
  resource_group_name   = azurerm_resource_group.avd.name
  subscription_id       = data.azurerm_client_config.current.subscription_id
  managed_identity_name = var.managed_identity_name
  location              = azurerm_resource_group.avd.location
  depends_on            = [azurerm_resource_group.avd]
}

module "monitoring" {
  source                              = "github.com/jonlake5/Azure-Virtual-Desktop//modules/monitoring/?ref=1.2.0"
  location                            = azurerm_resource_group.avd.location
  resource_group_name                 = azurerm_resource_group.avd.name
  policy_assignment_resource_group_id = azurerm_resource_group.avd.id
  law_name                            = var.log_analytics_workspace_name
  subscription_id                     = data.azurerm_client_config.current.subscription_id
  managed_identity_id                 = module.managed_identity.managed_identity_id
  action_group_name                   = var.action_group.name
  action_group_short_name             = var.action_group.short_name
  email_receivers                     = var.action_group.email_receivers
  depends_on                          = [azurerm_resource_group.avd]
}

module "policies" {
  source              = "./modules/policies"
  managed_identity_id = module.managed_identity.managed_identity_id
  resource_group_name = azurerm_resource_group.avd.name
  location            = azurerm_resource_group.avd.location
  depends_on          = [azurerm_resource_group.avd]
}

locals {
  all_application_groups = [for k, v in local.flattened_application_groups :
    v.application_group.application_group_assignnment_group_name
  ]
}

module "role_assignments" {
  source                              = "./modules/avd_role_assignments"
  resource_group_name                 = azurerm_resource_group.avd.name
  subscription_id                     = data.azurerm_client_config.current.subscription_id
  application_group_assignment_groups = toset(local.all_application_groups)
  depends_on                          = [azurerm_resource_group.avd]
}

module "shared_image_gallery" {
  source              = "./modules/image_gallery"
  location            = azurerm_resource_group.avd.location
  name                = var.shared_image_gallery_name
  resource_group_name = azurerm_resource_group.avd.name
  depends_on          = [azurerm_resource_group.avd]
}

module "shared_image" {
  for_each                  = var.images
  source                    = "./modules/image"
  location                  = azurerm_resource_group.avd.location
  resource_group_name       = azurerm_resource_group.avd.name
  shared_image_gallery_name = module.shared_image_gallery.name
  shared_image_name         = each.value.shared_image_name
  shared_image_sku          = each.value.shared_image_sku
  shared_image_offer        = each.value.shared_image_offer
  shared_image_publisher    = each.value.shared_image_publisher
  depends_on                = [module.shared_image_gallery, azurerm_resource_group.avd]
}

module "storage_account" {
  source                              = "./modules/storage_account"
  location                            = azurerm_resource_group.avd.location
  resource_group_name                 = azurerm_resource_group.avd.name
  pe_subnet_id                        = azurerm_subnet.avd.id
  smb_contributor_group_name          = var.storage_account.smb_contributor_group_name
  smb_elevated_contributor_group_name = var.storage_account.smb_elevated_contributor_group_name
  storage_account_name                = var.storage_account.storage_account_name
  storage_account_share               = var.storage_account.storage_account_share
  directory_config                    = var.storage_account.directory_config
  depends_on                          = [azurerm_resource_group.avd]
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
  depends_on                    = [azurerm_resource_group.avd]
}

output "managed_identity_account_id" {
  value = module.managed_identity.managed_identity_principal_id
}

output "keyvault_and_secret" {
  value = module.automation.keyvault_name_and_secret
}

output "maintenance_config_name" {
  value = module.updates.maintenance_config_name
}

output "webhook_uri" {
  value     = module.automation.webhook_url
  sensitive = true
}

output "packer_variables" {
  value = <<PACKER
subscription_id = "${data.azurerm_client_config.current.subscription_id}"
resource_group = "${var.resource_group_name}"
location = "${azurerm_resource_group.avd.location}"
image_gallery_name = "${var.shared_image_gallery_name}"
image_definition_name =  "${join(" | ", [for k, v in var.images : v.shared_image_name])}" #<---- Choose One
uami_object_id = "${module.managed_identity.managed_identity_id}"
new_image_version = "<version_desired_for_new_image>" #format is x.x.x
image_publisher = "microsoftwindowsdesktop"
image_offer = "windows-11"
image_sku = "win11-24h2-avd"
vm_size = "Standard_B2as_v2"
PACKER
}

