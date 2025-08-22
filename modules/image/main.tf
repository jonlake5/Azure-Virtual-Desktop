data "azurerm_client_config" "current" {}


resource "azurerm_shared_image" "avd-win11" {
  resource_group_name      = var.resource_group_name
  location                 = var.location
  name                     = var.shared_image_name
  gallery_name             = var.shared_image_gallery_name
  os_type                  = "Windows"
  hyper_v_generation       = var.hyper_v_generation
  trusted_launch_supported = true


  identifier {
    publisher = var.shared_image_publisher
    offer     = var.shared_image_offer
    sku       = var.shared_image_sku
  }
}
