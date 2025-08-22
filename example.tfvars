# Environment configuration. This region is where all of the resources will be placed. The tenant is the Entra tenant associated with the subscription.
location        = "northcentralus"
tenant_id       = "6d7e2966-xxxx-xxxx-xxxx-d9ec3af61a7c"
subscription_id = "074f4b99-xxxx-xxxx-xxxx-xxxxdb9d1e92"

# These are the basic constructs needed. Each of these will create exactly (1) resource of type: Resource Group, vNet, and subnet
resource_group_name = "rg-testing-avd-modules"

vnet_ip_space    = "10.0.0.0/16"
vnet_name        = "test-avd-vnet"
vnet_dns_servers = ["10.0.0.17", "8.8.8.8"]
subnet_name      = "test-avd-subnet"

# This will peer the vNet's defined in here 
vnet_peerings = {
  "avd_hub" = {
    name           = "avd-hub-peering"
    hub_vnet_id = "/subscriptions/074f4b99-ea66-4a73-a146-d342db9d1e92/resourceGroups/avd-testing-permanent/providers/Microsoft.Network/virtualNetworks/avd-hub"
    hub_vnet_name = "hub-vnet"
    spoke = {
      use_remote_gateways     = false #optional defaults to true
      allow_forwarded_traffic = false #optional defaults to true
      allow_virtual_network   = false #optional defaults to true
      allow_gateway_transit   = false #optional defaults to true
    }
    hub = {
      use_remote_gateways     = false #optional defaults to true
      allow_forwarded_traffic = false #optional defaults to true
      allow_virtual_network   = false #optional defaults to true
      allow_gateway_transit   = false #optional defaults to true
    }
  }
}

# This block defines all of the automation runbooks available. If enabled is set to false, the runbook is not created (or is removed if it was previously created)
automation_runbooks = {
  "enableScalingPlan" = {
    file_name = "enableScalingPlan.ps1"
    webhook   = true
    type      = "PowerShell72"
  }
  "disableScalingPlan" = {
    file_name = "disableScalingPlan.ps1"
    webhook   = true
    type      = "PowerShell72"
  }
  "createHost" = {
    file_name = "createHost.ps1"
    webhook   = true
    type      = "PowerShell72"
  }
  "addHostToSessionPoolDSC" = {
    file_name = "addHostToPool.ps1"
    webhook   = true
    type      = "PowerShell72"
  }
  "addHostToDomain" = {
    file_name = "addHostToDomain.ps1"
    webhook   = true
    type      = "PowerShell72"
    enabled   = false
  }
  "createRemediationTasks" = {
    file_name = "createRemediationTasks.ps1"
    webhook   = true
    type      = "PowerShell72"
  }
  "maintenanceConfig" = {
    file_name = "assignMaintenancePlanToVM.ps1"
    webhook   = true
    type      = "PowerShell72"
  }
}

#This block will create n number of dynamic Entra groups as defined in the block. These can also be created ahead of time for 
dynamic_host_groups = {
  "group1" = {
    groupName            = "AVD-HOSTS"
    groupFilterSubstring = "avd-"
  }
}


# This is the bulk of environment creation.
# It will create exactly one (1) AVD workspace, n number of hostpools, and y numer of application groups, z number of published applications.
# Currently it has only been tested with shared host pools. The naming of the keys have no bearing on resource naming or creation.
# Host pools can be created with no application groups, and applicaiton groups can be created with no applications published. 
# If the application group type is set to desktop, the applications block is ignored

environments = {
  "env1" = {
    workspace = {
      workspace_description   = "Workspace for AVD"
      workspace_friendly_name = "Workspace"
      workspace_name          = "workspace"
    }
    host_pools = {
      hp_1 = {
        auth_type               = "Entra"
        custom_rdp_properties   = "targetisaadjoined:i:1;enablecredsspsupport:i:1;videoplaybackmode:i:1;audiomode:i:0;devicestoredirect:s:*;drivestoredirect:s:*;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;redirectwebauthn:i:1;usbdevicestoredirect:s:*;use multimon:i:1;"
        load_balancer_type      = "BreadthFirst"
        host_pool_friendly_name = "Host Pool for App1"
        host_pool_name          = "hp-app2"
        host_pool_type          = "Pooled"
        scaling_plan_enabled    = true
        scaling_plan_name       = "weekdays_schedule_scaling_plan"
        scaling_plan_time_zone  = "Eastern Standard Time"
        scaling_plan_schedule = {
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
        application_groups = {
          app_grp_1 = {
            application_group_assignnment_group_name = "Duo AD Sync"
            application_group_name                   = "Network-Apps"
            application_group_type                   = "RemoteApp"
            applications = {
              "chrome" = {
                friendly_name = "Google Chrome"
                name          = "chrome"
                path          = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe"
              }
              "notepad" = {
                friendly_name = "Edge"
                name          = "edge"
                path          = "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe"
              }
            }
          }
          app_grp_2 = {
            application_group_assignnment_group_name = "Duo AD Sync"
            application_group_name                   = "SAP-Apps"
            application_group_type                   = "RemoteApp"
            applications = {
              "SAP" = {
                friendly_name = "SAP"
                name          = "sap"
                path          = "C:\\Program Files\\SAP\\sap.exe"
              }
              "iWidget" = {
                friendly_name = "iWidget"
                name          = "iwidget"
                path          = "C:\\Program Files (x86)\\iWidget\\iwidget.exe"
              }
            }
          }
          app_grp_3 = {
            application_group_assignnment_group_name = "Duo AD Sync"
            application_group_name                   = "AVDDesktop"
            application_group_type                   = "Desktop"
          }
        }
      }
      hp_2 = {
        auth_type               = "AD"
        load_balancer_type      = "DepthFirst"
        host_pool_friendly_name = "Host Pool for App3"
        host_pool_name          = "hp-app3"
        host_pool_type          = "Pooled"
        scaling_plan_enabled    = true
        scaling_plan_name       = "scaling_plan1"
        scaling_plan_time_zone  = "Eastern Standard Time"
        scaling_plan_schedule = {
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
        application_groups = {
          # app_grp_1 = {
          #   application_group_assignnment_group_name = "Duo AD Sync"
          #   application_group_name                   = "Server-Apps"
          #   application_group_type                   = "RemoteApp"
          #   applications = {
          #     "chrome" = {
          #       friendly_name = "Edge"
          #       name          = "edge"
          #       path          = "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe"
          #     }
          #   }
          # }
        }
      }
    }
  }
}

#These image blocks create n number of image definitions in the shared image gallery defined
shared_image_gallery_name = "NC_US_Shared_Gallery"
images = {
  "image_1" = {
    shared_image_name = "image-app-1"
    # shared_image_sku = "win2019"
    # shared_image_offer = "WindowsServer"
  }
  "image_2" = {
    shared_image_name = "image-app-2"
  }
}

#This block of maintenance definitions are created for VM patching using Azure Update Manager. It can be assigned to VMs when created with the Azure Automation runbook.
maintenance_definition = {
  "nightly_patching" = {
    maintenance_name            = "avd-nightly-patching"
    maintenance_scope           = "InGuestPatch"
    maintenance_duration        = "03:00"
    maintenance_start_date_time = "2025-06-04 22:30"
    # maintenance_end_date_time   = optional(string)
    maintenance_recurrence = "1Day"
    maintenance_time_zone  = "US Eastern Standard Time"
    # patch_classifications_to_include = ["Critical","Security"] - This is default if not explicitly set
    patch_classifications_to_include = ["Critical", "Security", "Updates"]
  }
}

# This block will create a Premium Azure File storage account.
# If directory config is set to either directory_type = AD or directory_type = AADKERB it will
# setup the configuration for either AD or Entra with Kerberos. Comments are placed on the lines
# stating which lines are required for each type of configuration. AADDS (managed Azure AD) has not 
# been tested and likely configuration will not work.
# For AD, the normal process of manually creating the storage object and setting the object password is still required.
storage_account = {
  smb_contributor_group_name          = "CORP-RDS-ACCESS"
  smb_elevated_contributor_group_name = "Duo AD Sync"
  storage_account_name                = "testavdstorageacct" # must be globally unique
  storage_account_share = {
    "share_1" = {
      name  = "fslogix-network"
      quota = 100
    }
    "share_2" = {
      name  = "fslogix-sap"
      quota = 100
    }
  }
  directory_config = {
    "config1" = {
      directory_type = "AD"
      active_directory_config = {
        domain_guid         = "31a09564-cd4a-4520-98fa-446a2af23b4b"          #AD and AADKERB
        domain_name         = "jlake.avd"                                     #AD and AADKERB
        domain_sid          = "S-1-5-21-149512832-3414834421-4071874907"      #AD only
        forest_name         = "jlake.avd"                                     #AD only
        netbios_domain_name = "jlake"                                         #AD only
        storage_sid         = "S-1-5-21-149512832-3414834421-4071874907-2604" #AD only
      }
    }
  }
}

#This will create one keyvault to store the password the automation account uses to join a VM to the domain.
# Keyvault names must be globally unique within Azure. 
# Keyvault_secret_name is not required and default value is domain-join-password

keyvault = {
  domain_join = {
    name = "avd-kv-jlake" #must be globally unique
    # keyvault_secret_name = "domain-join-password" # This is the default value
  }
}

# This is used in some policies to define what region(s) should be targeted for the policies.
policy_target_locations = ["northcentralus"]

#This defines an alert action group of people that should receive emails when an alert happens 
action_group = {
  name       = "ActionGroupAVD"
  short_name = "avd-ag"
  email_receivers = [{
    name                    = "Jonathan Lake"
    email_address           = "email.address@domain.com"
    use_common_alert_schema = true #optional - defaults to true
    },
    {
      name          = "Fred Smith"
      email_address = "email2.address@domain.com"
  }]
}