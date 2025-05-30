#Use the below block to create a host group for all hosts in this host pool

# resource "azuread_group" "avd_hosts" {
#   display_name     = "ENT-AVD-NOV-SESSION-HOSTS"
#   security_enabled = true
#   types            = ["DynamicMembership"]
#   dynamic_membership {
#     enabled = true
#     rule    = "device.systemLabels -any _ -eq \"AzureVirtualDesktop\""
#   }
# }


resource "azurerm_virtual_desktop_host_pool" "avd" {

  location            = var.location
  resource_group_name = var.resource_group_name

  name                     = var.host_pool_name
  friendly_name            = var.host_pool_friendly_name
  validate_environment     = var.validate_environment
  start_vm_on_connect      = var.start_vm_on_connect
  load_balancer_type       = var.load_balancer_type
  type                     = var.host_pool_type
  maximum_sessions_allowed = var.maximum_sessions_allowed
  scheduled_agent_updates {
    enabled                   = var.scheduled_agent_updates
    use_session_host_timezone = false
    timezone                  = "UTC"
    schedule {
      day_of_week = var.scheduled_agent_updates_day_of_week
      hour_of_day = var.scheduled_agent_updates_hour_of_day
    }
  }
  lifecycle {
    ignore_changes = [scheduled_agent_updates, load_balancer_type]
  }
}


resource "azurerm_virtual_desktop_host_pool_registration_info" "avd" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.avd.id
  expiration_date = timeadd(timestamp(), "${var.registration_key_valid_hours}h")
  lifecycle {
    ignore_changes = [expiration_date]
  }
}

resource "azurerm_virtual_desktop_scaling_plan" "weekdays" {

  resource_group_name = var.resource_group_name
  location            = var.location
  time_zone           = "Eastern Standard Time"
  name                = var.scaling_plan_name
  schedule {
    name                                 = "Weekdays_Schedule"
    days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    ramp_up_start_time                   = "07:30"
    ramp_up_load_balancing_algorithm     = "BreadthFirst"
    ramp_up_minimum_hosts_percent        = 40
    ramp_up_capacity_threshold_percent   = 60
    peak_start_time                      = "09:00"
    peak_load_balancing_algorithm        = "DepthFirst"
    ramp_down_start_time                 = "18:00"
    ramp_down_load_balancing_algorithm   = "DepthFirst"
    ramp_down_minimum_hosts_percent      = 20
    ramp_down_force_logoff_users         = false
    ramp_down_wait_time_minutes          = 45
    ramp_down_notification_message       = "Please log off in the next 45 minutes..."
    ramp_down_capacity_threshold_percent = 90
    ramp_down_stop_hosts_when            = "ZeroSessions"
    off_peak_start_time                  = "22:00"
    off_peak_load_balancing_algorithm    = "DepthFirst"
  }
  host_pool {
    scaling_plan_enabled = true
    hostpool_id          = azurerm_virtual_desktop_host_pool.avd.id
  }
  depends_on = [
    azurerm_virtual_desktop_host_pool.avd
  ]
}






output "hostpool_id" {
  value = azurerm_virtual_desktop_host_pool.avd.id
}
