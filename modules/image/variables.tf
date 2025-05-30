variable "golden_image_vm_name" {
  type        = string
  description = "VM Name of the golden image"
  validation {
    condition     = length(var.golden_image_vm_name) < 16
    error_message = "The value of golden_image_vm_name must be less than 15 characters"
  }
}

variable "golden_image_name" {
  type        = string
  description = "Name of the image that will be created to spawn the VM"
}

variable "hyper_v_generation" {
  type        = string
  description = "Hyper V Generation of the VM created"
  default     = "V2"
}


variable "local_admin_username" {
  type        = string
  description = "Local Admin Username of the Golden Image VM"
}

variable "local_admin_password" {
  type        = string
  sensitive   = true
  description = "Local Admin Password of the Golden Image VM"
}

variable "location" {
  type        = string
  description = "Location of the shared image gallery"
}

variable "resource_group_name" {
  type        = string
  description = "Name of resource group for the shared gallery"
}

variable "shared_image_gallery_name" {
  type        = string
  description = "Name of existing shared image gallery to put the shared image in"
}
variable "shared_image_name" {
  type        = string
  description = "Name of the shared image being created"
}

variable "shared_image_offer" {
  type        = string
  default     = "windows-11"
  description = "Offer of the source image the golden image will be created from"
}

variable "shared_image_publisher" {
  type        = string
  default     = "MyOrg"
  description = "Publisher of the source image the golden image will be created from"
}

variable "shared_image_sku" {
  type        = string
  description = "SKU of the source image the golden image will be created from"
}

variable "shared_image_version_name" {
  type        = string
  description = "Name of the shared image version"
}

variable "size" {
  type        = string
  description = "VM Size of the Golden Image"
  default     = "Standard_B2s"

}

variable "source_image_offer" {
  type        = string
  default     = "windows-11"
  description = "Offer of the source image the golden image will be created from"
}


variable "source_image_publisher" {
  type        = string
  default     = "MicrosoftWindowsDesktop"
  description = "Publisher of the source image the golden image will be created from"
}

variable "source_image_sku" {
  type        = string
  default     = "win11-24h2-avd"
  description = "SKU of the source image the golden image will be created from"
}

variable "source_image_version" {
  type        = string
  default     = "latest"
  description = "Version of the source image the golden image will be created from"
}

# locals {
#   offer_block = <<EOT
# {
#     publisher = "MicrosoftWindowsDesktop"
#     offer     = "windows-11"
#     sku       = "win11-24h2-avd
#     version   = "latest"
# }
# EOT
# }

variable "subscription_id" {
  type        = string
  description = "Subscription ID the resources are being deployed in"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID the golden image VM will be placed in"
}
