resource "azurerm_shared_image_gallery" "gallery" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  description         = var.description

}

output "name" {
  value = azurerm_shared_image_gallery.gallery.name
}
