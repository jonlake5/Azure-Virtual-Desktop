resource "azurerm_virtual_desktop_host_pool" "avd" {
  location                 = var.location
  resource_group_name      = var.resource_group_name
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

resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting" {
  name                       = "${azurerm_virtual_desktop_host_pool.avd.name}-diagnostic-setting"
  target_resource_id         = azurerm_virtual_desktop_host_pool.avd.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log {
    category_group = "AllLogs"
  }
}

resource "azurerm_virtual_desktop_scaling_plan" "weekdays" {
  count               = var.scaling_plan_schedule == null ? 0 : 1
  resource_group_name = var.resource_group_name
  location            = var.location
  time_zone           = var.scaling_plan_time_zone
  name                = var.scaling_plan_name
  schedule {
    name                                 = var.scaling_plan_schedule.name
    days_of_week                         = var.scaling_plan_schedule.days_of_week
    ramp_up_start_time                   = var.scaling_plan_schedule.ramp_up_start_time
    ramp_up_load_balancing_algorithm     = var.scaling_plan_schedule.ramp_up_load_balancing_algorithm
    ramp_up_minimum_hosts_percent        = var.scaling_plan_schedule.ramp_up_minimum_hosts_percent
    ramp_up_capacity_threshold_percent   = var.scaling_plan_schedule.ramp_up_capacity_threshold_percent
    peak_start_time                      = var.scaling_plan_schedule.peak_start_time
    peak_load_balancing_algorithm        = var.scaling_plan_schedule.peak_load_balancing_algorithm
    ramp_down_start_time                 = var.scaling_plan_schedule.ramp_down_start_time
    ramp_down_load_balancing_algorithm   = var.scaling_plan_schedule.ramp_down_load_balancing_algorithm
    ramp_down_minimum_hosts_percent      = var.scaling_plan_schedule.ramp_down_minimum_hosts_percent
    ramp_down_force_logoff_users         = var.scaling_plan_schedule.ramp_down_force_logoff_users
    ramp_down_wait_time_minutes          = var.scaling_plan_schedule.ramp_down_wait_time_minutes
    ramp_down_notification_message       = var.scaling_plan_schedule.ramp_down_notification_message
    ramp_down_capacity_threshold_percent = var.scaling_plan_schedule.ramp_down_capacity_threshold_percent
    ramp_down_stop_hosts_when            = var.scaling_plan_schedule.ramp_down_stop_hosts_when
    off_peak_start_time                  = var.scaling_plan_schedule.off_peak_start_time
    off_peak_load_balancing_algorithm    = var.scaling_plan_schedule.off_peak_load_balancing_algorithm
  }
  host_pool {
    scaling_plan_enabled = var.scaling_plan_enabled
    hostpool_id          = azurerm_virtual_desktop_host_pool.avd.id
  }
  depends_on = [
    azurerm_virtual_desktop_host_pool.avd
  ]
}


output "hostpool_id" {
  value = azurerm_virtual_desktop_host_pool.avd.id
}
