variable "description" {
  type        = string
  default     = "Share Image Gallery for hosting AVD images"
  description = "Description of the shared image gallery"
}

variable "location" {
  type        = string
  description = "Location of the shared image gallery"
}

variable "name" {
  type        = string
  description = "Name of the shared image gallery"
}


variable "resource_group_name" {
  type        = string
  description = "Name of resource group for the shared gallery"
}
