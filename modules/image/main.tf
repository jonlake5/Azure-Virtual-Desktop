data "azurerm_client_config" "current" {}

resource "azurerm_network_interface" "golden_image" {
  name                = "${var.golden_image_vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "golden-image" {
  name                = var.golden_image_vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size
  admin_password      = var.local_admin_password
  admin_username      = var.local_admin_username
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  network_interface_ids = [azurerm_network_interface.golden_image.id]

  source_image_reference {
    publisher = var.source_image_publisher
    offer     = var.source_image_offer
    sku       = var.source_image_sku
    version   = var.source_image_version
  }
  depends_on = [azurerm_network_interface.golden_image]

}

## Wait on generalization to happen
resource "time_sleep" "wait_after_generalize" {
  depends_on       = [azapi_resource_action.generalize_vm]
  create_duration  = "120s"
  destroy_duration = "1s"
}

resource "azurerm_virtual_machine_run_command" "sysprep" {
  name               = "vm-run-command-sysprep"
  location           = var.location
  virtual_machine_id = azurerm_windows_virtual_machine.golden-image.id
  source {
    script = "c:\\windows\\System32\\Sysprep\\sysprep.exe /oobe /generalize /shutdown"
  }
  depends_on = [azurerm_windows_virtual_machine.golden-image]
  lifecycle {
    prevent_destroy = true
  }
}

resource "time_sleep" "wait_after_sysprep" {
  depends_on       = [azurerm_virtual_machine_run_command.sysprep]
  create_duration  = "120s"
  destroy_duration = "1s"
}

resource "azapi_resource_action" "generalize_vm" {
  type        = "Microsoft.Compute/virtualMachines@2022-03-01"
  resource_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Compute/virtualMachines/${azurerm_windows_virtual_machine.golden-image.name}"
  action      = "generalize"
  method      = "POST"
  depends_on = [
    time_sleep.wait_after_sysprep, azurerm_virtual_machine_run_command.sysprep
  ]
}

resource "azurerm_image" "golden_image" {
  name                      = var.golden_image_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  source_virtual_machine_id = azurerm_windows_virtual_machine.golden-image.id
  hyper_v_generation        = var.hyper_v_generation


  depends_on = [time_sleep.wait_after_generalize, azapi_resource_action.generalize_vm]
}


resource "azurerm_shared_image" "avd-win11" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.shared_image_name
  gallery_name        = var.shared_image_gallery_name
  os_type             = "Windows"
  hyper_v_generation  = var.hyper_v_generation
  identifier {
    publisher = var.shared_image_publisher
    offer     = var.shared_image_offer
    sku       = var.shared_image_sku
  }
  depends_on = [azurerm_image.golden_image]
}

resource "azurerm_shared_image_version" "win11-avd" {
  name                = var.shared_image_version_name
  gallery_name        = var.shared_image_gallery_name
  image_name          = azurerm_shared_image.avd-win11.name
  resource_group_name = var.resource_group_name
  location            = var.location
  managed_image_id    = azurerm_image.golden_image.id

  target_region {
    name                   = azurerm_shared_image.avd-win11.location
    regional_replica_count = 1
    storage_account_type   = "Standard_LRS"
  }
  depends_on = [azurerm_shared_image.avd-win11]
}
