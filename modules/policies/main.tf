resource "azurerm_policy_definition" "vm_system_assigned_managed_identity" {
  name                = "configure-system-assigned-managed-identity-custom"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Configure VM to use System Assigned Managed Identity (Custom)"
  description         = "Ensure VMs are configured to use a System Assigned Managed Identity"
  management_group_id = null # or use if needed
  parameters          = <<PARAMS
{
    "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "Enable or disable the execution of the policy"
        },
        "allowedValues": [
          "Modify",
          "Disabled"
        ],
        "defaultValue": "Modify"
      }
    }
PARAMS
  metadata = jsonencode({
    category = "Azure Compute"
    version  = "1.0.0"
  })

  policy_rule = <<RULE
  {
  "if": {
    "allOf": [
      {
        "anyOf": [
          {
            "field": "type",
            "equals": "Microsoft.Compute/virtualMachines"
          },
          {
            "field": "type",
            "equals": "Microsoft.Compute/virtualMachineScaleSets"
          }
        ]
      },
      {
        "field": "identity.type",
        "notContains": "SystemAssigned"
      },
      {
        "value": "[requestContext().apiVersion]",
        "greaterOrEquals": "2018-10-01"
      },
      {
        "field": "location",
        "in": [
          "australiacentral",
          "australiaeast",
          "australiasoutheast",
          "brazilsouth",
          "canadacentral",
          "canadaeast",
          "centralindia",
          "centralus",
          "centraluseuap",
          "eastasia",
          "eastus",
          "eastus2",
          "eastus2euap",
          "francecentral",
          "germanywestcentral",
          "japaneast",
          "japanwest",
          "jioindiawest",
          "koreacentral",
          "koreasouth",
          "northcentralus",
          "northeurope",
          "norwayeast",
          "qatarcentral",
          "southafricanorth",
          "southcentralus",
          "southeastasia",
          "southindia",
          "swedencentral",
          "switzerlandnorth",
          "uaenorth",
          "uksouth",
          "ukwest",
          "westcentralus",
          "westeurope",
          "westindia",
          "westus",
          "westus2",
          "westus3"
        ]
      }
    ]
  },
  "then": {
    "effect": "[parameters('effect')]",
    "details": {
      "roleDefinitionIds": [
        "/providers/microsoft.authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c",
        "/providers/microsoft.authorization/roleDefinitions/e40ec5ca-96e0-45a2-b4ff-59039f2c2b59",
        "/providers/microsoft.authorization/roleDefinitions/f1a07417-d97a-45cb-824c-7a7467783830"
      ],
      "operations": [
        {
          "operation": "addOrReplace",
          "field": "identity.type",
          "value": "[if(contains(field('identity.type'), 'UserAssigned'), concat(field('identity.type'), ',SystemAssigned'), 'SystemAssigned')]"
        }
      ]
    }
  }
}
RULE
}


data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

resource "azurerm_resource_group_policy_assignment" "system_assigned_identity_role" {
  resource_group_id    = data.azurerm_resource_group.resource_group.id
  policy_definition_id = azurerm_policy_definition.vm_system_assigned_managed_identity.id
  name                 = "System Assigned Managed Identity"
  location             = var.location
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }
}
