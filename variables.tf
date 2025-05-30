variable "domain_join_password" {
  type        = string
  description = "Password used to join AVD hosts to the domain. This will be populated into an azure keyvault for Azure Automation"
}
variable "domain_join_username" {
  type        = string
  description = "Username used to join AVD hosts to the domain"
}

variable "images" {
  type = map(object({
    golden_image_name    = string
    golden_image_vm_name = string
    local_admin_password = string
    local_admin_username = string
    shared_image_name    = string
    shared_image_sku     = string
  }))
  validation {
    condition = alltrue([
      for image in var.images : length(image.golden_image_vm_name) <= 15
    ])
    error_message = "Each golden_image_vm_name must be 15 characters or fewer."
  }
}


variable "environments" {
  type = map(object({
    workspace = object({
      workspace_description   = string
      workspace_name          = string
      workspace_friendly_name = string
    })
    host_pools = map(object({
      load_balancer_type      = string
      host_pool_friendly_name = string
      host_pool_name          = string
      host_pool_type          = string
      scaling_plan_name       = string
      application_groups = optional(map(object({

        application_group_assignnment_group_name = string
        application_group_name                   = string
        application_group_type                   = string
        applications = optional(map(object({
          friendly_name = string
          name          = string
          path          = string
        })))
      })))
    }))
  }))
}



variable "storage_account" {
  type = object({
    smb_contributor_group_name          = string
    smb_elevated_contributor_group_name = string
    storage_account_name                = string
    # storage_account_share = map(object({
    #   name  = string
    #   quota = number
    # }))
  })
}

variable "storage_account_share" {
  type = map(object({
    name  = string
    quota = number
  }))
}

