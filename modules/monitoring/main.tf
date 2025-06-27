# Create module that will setup log analytics workspace, data collection rules, apply policy to install agent on hosts, etc
data "azurerm_resource_group" "avd" {
  name = var.resource_group_name
}

resource "azurerm_log_analytics_workspace" "workspace" {
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = var.law_name
}


resource "azurerm_resource_group_policy_assignment" "ama_install" {
  name                 = var.ama_install_policy_assignment_name
  resource_group_id    = var.policy_assignment_resource_group_id
  location             = var.location
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ca817e41-e85a-4783-bc7f-dc532d36235e"
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }
  parameters = <<PARAMS
{
  "scopeToSupportedImages": {
    "value":false
  }
}
PARAMS
}

resource "azurerm_monitor_data_collection_rule" "avd_session_hosts" {
  name                = "microsoft-avdi-${var.location}"
  resource_group_name = var.resource_group_name
  location            = var.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
      name                  = "LogAnalyticsDestination"
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf", "Microsoft-Event"]
    destinations = ["LogAnalyticsDestination"]
  }

  data_sources {
    performance_counter {
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 30
      counter_specifiers = [
        "\\LogicalDisk(C:)\\Avg. Disk Queue Length",
        "\\LogicalDisk(C:)\\Current Disk Queue Length",
        "\\Memory\\Available Mbytes",
        "\\Memory\\Page Faults/sec",
        "\\Memory\\Pages/sec",
        "\\Memory\\% Committed Bytes In Use",
        "\\PhysicalDisk(*)\\Avg. Disk Queue Length",
        "\\PhysicalDisk(*)\\Avg. Disk sec/Read",
        "\\PhysicalDisk(*)\\Avg. Disk sec/Transfer",
        "\\PhysicalDisk(*)\\Avg. Disk sec/Write",
        "\\Processor Information(_Total)\\% Processor Time",
        "\\User Input Delay per Process(*)\\Max Input Delay",
        "\\User Input Delay per Session(*)\\Max Input Delay"
      ]
      name = "perfCounterDataSource"
    }
    performance_counter {
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 30
      counter_specifiers = [
        "\\LogicalDisk(C:)\\% Free Space",
        "\\LogicalDisk(C:)\\Avg. Disk sec/Transfer"
      ]
      name = "perfCounterDataSource60"
    }

    windows_event_log {
      streams = ["Microsoft-Event"]
      x_path_queries = [
        "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Admin!*[System[(Level=2 or Level=3 or Level=4 or Level=0)]]",
        "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational!*[System[(Level=2 or Level=3 or Level=4 or Level=0)]]",
        "System!*",
        "Microsoft-FSLogix-Apps/Operational!*[System[(Level=2 or Level=3 or Level=4 or Level=0)]]",
        "Application!*[System[(Level=2 or Level=3)]]",
        "Microsoft-FSLogix-Apps/Admin!*[System[(Level=2 or Level=3 or Level=4 or Level=0)]]"
      ]
      name = "eventLogsDataSource"
    }
  }

  description = "Data collection rule for Azure Virtual Desktop session hosts"
}

resource "azurerm_resource_group_policy_assignment" "associate_dcr" {
  name                 = "Associate DCR with Session Hosts"
  resource_group_id    = var.policy_assignment_resource_group_id
  location             = var.location
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/eab1f514-22e3-42e3-9a1f-e1dc9199355c"
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }
  parameters = <<PARAMS
  {
    "dcrResourceId": {
      "value":"${azurerm_monitor_data_collection_rule.avd_session_hosts.id}"
    },
    "scopeToSupportedImages": {
    "value":false
    }
  }
PARAMS
}



output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.workspace.id
}

