# #Workspace
module "workspace" {
  source                  = "./modules/avd_workspace"
  for_each                = var.environments
  location                = azurerm_resource_group.avd.location
  resource_group_name     = azurerm_resource_group.avd.name
  workspace_description   = each.value.workspace.workspace_description
  workspace_friendly_name = each.value.workspace.workspace_friendly_name
  workspace_name          = each.value.workspace.workspace_name
}

locals {
  flattened_host_pools = {
    for hp in flatten([
      for env_name, env in var.environments : [
        for host_pool_key, host_pool in env.host_pools : {
          key = "${env_name}.${host_pool_key}"
          value = {
            environment   = env_name
            host_pool_key = host_pool_key
            host_pool     = host_pool
          }
        }
      ]
    ]) : hp.key => hp.value
  }
}

module "host_pool" {
  source = "./modules/host_pool"

  for_each = local.flattened_host_pools

  resource_group_name     = azurerm_resource_group.avd.name
  location                = azurerm_resource_group.avd.location
  load_balancer_type      = each.value.host_pool.load_balancer_type
  host_pool_friendly_name = each.value.host_pool.host_pool_friendly_name
  host_pool_name          = each.value.host_pool.host_pool_name
  host_pool_type          = each.value.host_pool.host_pool_type
  scaling_plan_enabled    = each.value.host_pool.scaling_plan_enabled
  scaling_plan_name       = each.value.host_pool.scaling_plan_name
  scaling_plan_schedule   = each.value.host_pool.scaling_plan_schedule
  scaling_plan_time_zone  = each.value.host_pool.scaling_plan_time_zone
}

#Application Group
locals {
  flattened_application_groups = {
    for key, ag in flatten([
      for env_name, env in var.environments : [
        for host_pool_key, host_pool in env.host_pools : [
          for ag_key, ag in try(host_pool.application_groups, {}) : {
            key = "${env_name}.${host_pool_key}.${ag_key}"
            value = {
              environment       = env_name
              host_pool_key     = host_pool_key
              application_group = ag
            }
          }
        ]
      ]
    ]) : key => ag.value
  }
}

module "application_group" {
  source = "./modules/application_group"

  for_each = local.flattened_application_groups

  application_group_assignnment_group_name = each.value.application_group.application_group_assignnment_group_name
  application_group_name                   = each.value.application_group.application_group_name
  application_group_type                   = each.value.application_group.application_group_type
  applications                             = try(each.value.application_group.applications, [])
  workspace_id                             = module.workspace[each.value.environment].workspace_id
  resource_group_name                      = azurerm_resource_group.avd.name
  location                                 = azurerm_resource_group.avd.location
  host_pool_id                             = module.host_pool["${each.value.environment}.${each.value.host_pool_key}"].hostpool_id
}



