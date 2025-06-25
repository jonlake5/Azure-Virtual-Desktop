# ================================================
# Azure Monitor Action Group (for all alerts)
# ================================================
resource "azurerm_monitor_action_group" "avd_alert_actiongroup" {
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = var.action_group_short_name
  dynamic "email_receiver" {
    for_each = var.email_receivers
    content {
      name                    = email_receiver.value["name"]
      email_address           = email_receiver.value["email_address"]
      use_common_alert_schema = email_receiver.value["use_common_alert_schema"]
    }
  }
}

# ================================================
# High CPU Alert for AVD Session Host
# ================================================
resource "azurerm_monitor_metric_alert" "cpu_high_alert" {
  name                     = "avd-high-cpu-alert"
  resource_group_name      = var.resource_group_name
  scopes                   = [data.azurerm_resource_group.avd.id] # azurerm_windows_virtual_machine.example.id] # or your VMSS ID
  description              = "Triggered when CPU usage is over 80% for 5 minutes"
  severity                 = 2
  enabled                  = true
  target_resource_type     = "Microsoft.Compute/virtualMachines"
  target_resource_location = var.location
  frequency                = "PT1M"
  window_size              = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.avd_alert_actiongroup.id
  }
}

# ================================================
# Low Available Memory Alert for AVD Session Host
# ================================================
resource "azurerm_monitor_metric_alert" "low_memory_alert" {
  name                     = "avd-low-memory-alert"
  resource_group_name      = var.resource_group_name
  scopes                   = [data.azurerm_resource_group.avd.id] # or your VMSS ID
  description              = "Alert when available memory is below 500MB"
  severity                 = 2
  enabled                  = true
  target_resource_type     = "Microsoft.Compute/virtualMachines"
  target_resource_location = var.location
  frequency                = "PT1M"
  window_size              = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 524288000 # 500MB in bytes
  }

  action {
    action_group_id = azurerm_monitor_action_group.avd_alert_actiongroup.id
  }
}

# ================================================
# Log Analytics Alert - Failed WVD User Connections
# ================================================
resource "azurerm_monitor_scheduled_query_rules_alert" "wvd_failed_connections" {
  name                = "wvd-failed-connections-alert"
  resource_group_name = var.resource_group_name
  location            = var.location
  enabled             = true
  severity            = 2
  frequency           = 5
  time_window         = 10

  description = "Alert when more than 5 WVD failed connections in a 10-minute window"

  data_source_id = azurerm_log_analytics_workspace.workspace.id

  query = <<-QUERY
    WVDConnections
    | where ConnectionStatus == "Failed"
    | summarize FailedCount = count() by bin(TimeGenerated, 5m)
    | where FailedCount > 5
  QUERY

  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }

  action {
    action_group = [azurerm_monitor_action_group.avd_alert_actiongroup.id]
  }
}
