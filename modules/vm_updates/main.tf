resource "azurerm_resource_group_policy_assignment" "update_prereqs" {
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/9905ca54-1471-49c6-8291-7582c04cd4d4"
  resource_group_id    = var.resource_group_id
  location             = var.location
  name                 = "Prerequisites for recurring updates on Azure virtual machines"
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }
  parameters = jsonencode({
    "locations" : {
      "value" : var.policy_target_locations
    }
  })
}


resource "azurerm_resource_group_policy_assignment" "check_updates" {
  policy_definition_id = azurerm_policy_definition.vm_update_check_custom.id
  resource_group_id    = var.resource_group_id
  location             = var.location
  name                 = "Periodically check for missing system updates"
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }
  parameters = jsonencode({
    "locations" : {
      "value" : var.policy_target_locations
    }
  })
}


resource "azurerm_policy_definition" "vm_update_check_custom" {
  name                = "configure-periodic-update-check-custom"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Configure periodic checking for missing system updates (Custom)"
  description         = "Ensure VMs are onboarded to update assessments (works for SIG images too)"
  management_group_id = null # or use if needed
  parameters          = <<PARAMS
{
      "assessmentMode": {
        "type": "String",
        "metadata": {
          "displayName": "Assessment mode",
          "description": "Assessment mode for the machines."
        },
        "allowedValues": [
          "ImageDefault",
          "AutomaticByPlatform"
        ],
        "defaultValue": "AutomaticByPlatform"
      },
      "osType": {
        "type": "String",
        "metadata": {
          "displayName": "OS type",
          "description": "OS type for the machines."
        },
        "allowedValues": [
          "Windows",
          "Linux"
        ],
        "defaultValue": "Windows"
      },
      "locations": {
        "type": "Array",
        "metadata": {
          "displayName": "Machines locations",
          "description": "The list of locations from which machines need to be targeted.",
          "strongType": "location"
        },
        "defaultValue": []
      },
      "tagValues": {
        "type": "Object",
        "metadata": {
          "displayName": "Tags on machines",
          "description": "The list of tags that need to matched for getting target machines."
        },
        "defaultValue": {}
      },
      "tagOperator": {
        "type": "String",
        "metadata": {
          "displayName": "Tag operator",
          "description": "Matching condition for resource tags"
        },
        "allowedValues": [
          "All",
          "Any"
        ],
        "defaultValue": "Any"
      }
    }
PARAMS
  metadata = jsonencode({
    category = "Azure Update Managerr"
    version  = "1.0.0"
  })

  policy_rule = <<RULE
{
"if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Compute/virtualMachines"
          },
          {
            "anyOf": [
              {
                "value": "[empty(parameters('locations'))]",
                "equals": true
              },
              {
                "field": "location",
                "in": "[parameters('locations')]"
              }
            ]
          },
          {
            "field": "[if(equals(tolower(parameters('osType')), 'windows'), 'Microsoft.Compute/virtualMachines/osProfile.windowsConfiguration.patchSettings.assessmentMode', 'Microsoft.Compute/virtualMachines/osProfile.linuxConfiguration.patchSettings.assessmentMode')]",
            "notEquals": "[parameters('assessmentMode')]"
          },
          {
            "anyOf": [
              {
                "value": "[empty(parameters('tagValues'))]",
                "equals": true
              },
              {
                "allOf": [
                  {
                    "value": "[parameters('tagOperator')]",
                    "equals": "Any"
                  },
                  {
                    "value": "[greaterOrEquals(if(empty(field('tags')), 0, length(intersection(parameters('tagValues'), field('tags')))), 1)]",
                    "equals": true
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "value": "[parameters('tagOperator')]",
                    "equals": "All"
                  },
                  {
                    "value": "[equals(if(empty(field('tags')), 0, length(intersection(parameters('tagValues'), field('tags')))), length(parameters('tagValues')))]",
                    "equals": true
                  }
                ]
              }
            ]
          }
        ]
      },
      "then": {
        "effect": "modify",
        "details": {
          "roleDefinitionIds": [
            "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
          ],
          "conflictEffect": "audit",
          "operations": [
            {
              "condition": "[equals(tolower(parameters('osType')), 'windows')]",
              "operation": "addOrReplace",
              "field": "Microsoft.Compute/virtualMachines/osProfile.windowsConfiguration.patchSettings.assessmentMode",
              "value": "[parameters('assessmentMode')]"
            },
            {
              "condition": "[equals(tolower(parameters('osType')), 'linux')]",
              "operation": "addOrReplace",
              "field": "Microsoft.Compute/virtualMachines/osProfile.linuxConfiguration.patchSettings.assessmentMode",
              "value": "[parameters('assessmentMode')]"
            }
          ]
        }
      }
}

RULE
}

resource "azurerm_maintenance_configuration" "patch_window" {
  for_each            = var.maintenance_definition
  name                = each.value.maintenance_name
  scope               = each.value.maintenance_scope
  resource_group_name = var.resource_group_name
  location            = var.location
  window {
    start_date_time      = each.value.maintenance_start_date_time
    time_zone            = each.value.maintenance_time_zone
    expiration_date_time = each.value.maintenance_end_date_time
    duration             = each.value.maintenance_duration
    recur_every          = each.value.maintenance_recurrence
  }
}
