variable "hyper_v_generation" {
  type        = string
  description = "Hyper V Generation of the VM created"
  default     = "V2"
}

variable "location" {
  type        = string
  description = "Location of the shared image gallery image"
}

variable "resource_group_name" {
  type        = string
  description = "Name of resource group for the shared gallery image"
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
